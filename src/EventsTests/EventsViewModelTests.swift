@testable import Events
import OHHTTPStubs
import RxCocoa
import RxSwift
import RxTest
import XCTest

class EventsViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var sut: EventsViewModel!
    var storage: LocalStorage!
    var api: API!
    var networkProvider: NetworkProvider!
    var eventService: EventService!
    var expectedItems: [Item]!

    let responseJSON: String =
        """
        {
            "events": {
                "event": [
                    {
                        "url": "test_url_1",
                        "id": "E0-001-132531203-1@2019113010",
                        "start_time": "2020-01-26 09:00:00",
                        "title": "https://foodpenther.com/black-label-x/"
                    },
                    {
                        "url": "test_url_2",
                        "id": "E0-001-132472166-7",
                        "start_time": "2020-01-25 09:00:00",
                        "title": "WORKSHOP: Integrating Sustainable Practices into Your Native Garden"
                    }
                ]
            }
        }
        """

    override func setUp() {
        super.setUp()
        stub(condition: isMethodGET()) { _ in
            let stubData = self.responseJSON.data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data: stubData!,
                                       statusCode: 200,
                                       headers: nil)
        }
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        storage = LocalStorage(with: StorageKeys(favorite: "favorite_test",
                                                 events: "events_test"))
        storage.input.cleanAll.on(.next(()))
        networkProvider = NetworkProvider()
        api = API(networkProvider: networkProvider)
        eventService = EventService(api: api, storage: storage)
        let eventData = try! JSONDecoder().decode(EventsData.self, from: responseJSON.data(using: String.Encoding.utf8)!)
        expectedItems = eventData.events.event.map { Item(event: $0, isFavorite: false) }
        sut = EventsViewModel(with: eventService)
    }

    override func tearDown() {
        super.tearDown()
        storage.input.cleanAll.on(.next(()))
        storage = nil
        sut = nil
        disposeBag = nil
        scheduler = nil
        api = nil
        networkProvider = nil
        eventService = nil
        expectedItems = nil
        OHHTTPStubs.removeAllStubs()
    }

    func testInitialItemsShouldBeenRefreshed() {
        let itemsRefreshed = expectation(description: "Items refreshing fulfilled")

        sut.output.items.drive(onNext: { items in
            XCTAssertEqual(items, self.expectedItems, "Items doesn't match")
            itemsRefreshed.fulfill()
        }).disposed(by: disposeBag)

        sut.output.error.drive(onNext: { error in
            XCTFail("An error has occurred: \(error)")
        }).disposed(by: disposeBag)

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("Timeout errored: \(error)")
            }
        }
    }

    func testErrorCatched() {
        let errorExpectation = expectation(description: "Error fulfilled")
        stub(condition: isMethodGET()) { _ in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
            return OHHTTPStubsResponse(error: notConnectedError)
        }

        sut.output.error.drive(onNext: { _ in
            errorExpectation.fulfill()
        }).disposed(by: disposeBag)

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("Timeout errored: \(error)")
            }
        }
    }

    func testFavoriteTapCallsStorage() {
        let expectedEvent = Event(id: "test_id_1", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")

        // Create scheduler
        let action = scheduler.createObserver(Event.self)

        // Binding
        storage.input.swapFavoriteMark
            .bind(to: action)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(10, expectedEvent)])
            .bind(to: sut.input.tapFavorite)
            .disposed(by: disposeBag)

        // Run sheduler execution
        scheduler.start()

        XCTAssertEqual(action.events, [.next(10, expectedEvent)], "Expected Items doesn't match")
        XCTAssertEqual(storage.getFavorites(), [expectedEvent], "Storage didn't changed")

        scheduler.createColdObservable([.next(20, expectedEvent)])
            .bind(to: sut.input.tapFavorite)
            .disposed(by: disposeBag)

        // Run sheduler execution second time
        scheduler.start()

        XCTAssertEqual(action.events, [.next(10, expectedEvent), .next(30, expectedEvent)], "Expected Items doesn't match")
        XCTAssertEqual(storage.getFavorites(), [], "Unmark doesn't work")
    }

    func testSelectionItemCallsHelper() {
        let expectedEvent = Event(id: "test_id_1", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")
        let expectedItem = Item(event: expectedEvent, isFavorite: true)

        scheduler.createColdObservable([.next(10, expectedItem)])
            .bind(to: sut.input.selectedItem)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(OpenURLHelper.shared.lastURL, expectedEvent.url, "Expected URL doesn't match")
    }

    func testTimerExecution() {
        let timerExpectation = expectation(description: "Timer fulfilled")

        sut = EventsViewModel(with: eventService, timerPeriod: 1)

        sut.output.timerExecution.subscribe(onNext: {
            timerExpectation.fulfill()
        }).disposed(by: disposeBag)

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("Timeout errored: \(error)")
            }
        }
    }
}
