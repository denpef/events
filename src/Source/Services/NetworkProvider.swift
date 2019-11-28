import RxCocoa
import RxSwift

final class NetworkProvider {
    private let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.APIFormatter)
        return decoder
    }()

//    func request<T: Decodable>(url: String) -> Observable<Result<T, NetworkError>> {
//        guard let url = URL(string: url) else {
//            return Observable.of(.failure(NetworkError.badURL))
//        }
//        let request = URLRequest(url: url)
//        return urlSession.rx.data(request: request)
//            .observeOn(Scheduler.network)
//            .map { data -> Result<T, NetworkError> in
//                do {
//                    // swiftlint:disable force_cast
//                    let value = try self.decoder.decode(T.self, from: data) // as! [String: Any])["events"] as! [String: Any])["event"] as! T
//                    return .success(value)
//                } catch {
//                    return .failure(.decodingError(error))
//                }
//            }
//            .catchError {
//                .just(.failure(.decodingError($0)))
//            }
//    }

//    func request<T: Decodable>(url: String) -> Observable<[T]> {
//        return Observable.create { observer -> Disposable in
//            guard let url = URL(string: url) else {
//                observer.on(.error(NetworkError.badURL))
//            }
//            return urlSession.rx.data(request: URLRequest(url: url))
//                .observeOn(Scheduler.network)
//                .map { data -> Disposable in
//                    do {
//                        let value = try self.decoder.decode(T.self, from: data)
//                        observer.on(.next(value))
//                    } catch {
//                        observer.on(.error(NetworkError.decodingError(error)))
//                    }
//                    return Disposables.create()
//                }
    ////                .catchError {
    ////                    observer.on(.error(NetworkError.decodingError($0)))
    ////                }
//        }
//    }

    func request<T: Decodable>(url: String) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let url = URL(string: url), let self = self else {
                observer.on(.error(NetworkError.badURL))
                return Disposables.create()
            }
            return self.urlSession.rx.data(request: URLRequest(url: url))
                .observeOn(Scheduler.network)
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
