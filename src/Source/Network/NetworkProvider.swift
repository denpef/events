import RxCocoa
import RxSwift

/// The class responsible for executing the request works at the URLSession level
///
final class NetworkProvider {
    // MARK: - Private properties

    private let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.APIFormatter)
        return decoder
    }()

    private lazy var networkScheduler: ImmediateSchedulerType = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = .userInitiated
        operationQueue.name = "NS"
        return OperationQueueScheduler(operationQueue: operationQueue)
    }()

    // MARK: - Methods

    /// Query execution, decoding result in json
    /// In case of an error, throw it one level higher
    ///
    /// - Parameter url: full URL path
    func request<T: Decodable>(url: String) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let url = URL(string: url), let self = self else {
                observer.on(.error(NetworkError.badURL))
                return Disposables.create()
            }

            return self.urlSession.rx.data(request: URLRequest(url: url))
                .observeOn(self.networkScheduler)
                .subscribe(onNext: { data in
                    do {
                        let value = try self.decoder.decode(T.self, from: data)
                        observer.on(.next(value))
                    } catch {
                        observer.on(.error(NetworkError.decodingError(error)))
                    }
                }, onError: { _ in
                    observer.on(.error(NetworkError.badURL))
                })
        }
    }
}
