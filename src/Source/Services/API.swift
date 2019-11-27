import RxSwift

final class API {
    private let networkProvider: NetworkProvider
    private let eventPath = "http://api.eventful.com/json/events/search?app_key=CKKnt488bNT6HK2c&keywords=books&location=San+Diego&date=Future"

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func getEvents() -> Observable<Result<[Event], NetworkError>> {
        return networkProvider.request(url: eventPath)
    }
}
