import RxCocoa
import RxSwift

final class NetworkProvider {
    private let urlSession: URLSession
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.APIFormatter)
        return decoder
    }()

    private init() {
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
    }

    func request<T: Decodable>(url: String) -> Observable<Result<T, NetworkError>> {
        guard let url = URL(string: url) else {
            return Observable.of(.failure(NetworkError.badURL))
        }
        let request = URLRequest(url: url)
        return urlSession.rx.data(request: request)
            .observeOn(Scheduler.network)
            .map { data -> Result<T, NetworkError> in
                do {
                    let value = try self.decoder.decode(T.self, from: data)
                    return .success(value)
                } catch {
                    return .failure(.decodingError(error))
                }
            }
            .catchError {
                .just(.failure(.decodingError($0)))
            }
    }
}
