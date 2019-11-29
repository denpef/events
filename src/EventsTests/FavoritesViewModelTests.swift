@testable import Events
import RxCocoa
import RxSwift
import RxTest
import XCTest

class FavoritesViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var sut: FavoritesViewModel!
    var storage: LocalStorage!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        storage = LocalStorage(with: StorageKeys(favorite: "favorite_test", events: "events_test"))
        storage.input.cleanAll.on(.next(()))
        sut = FavoritesViewModel(storage: storage)
    }

    override func tearDown() {
        super.tearDown()
        storage.input.cleanAll.on(.next(()))
        sut = nil
        disposeBag = nil
        scheduler = nil
    }

    func testInitialStoreIsEmpty() {
        XCTAssertEqual(storage.getEvents(), [], "Initial events doesn't empty")
        XCTAssertEqual(storage.getFavorites(), [], "Initial favorites doesn't empty")
    }

    func testInitialStoreIsFilledOneValue() {
        let expectedEvent = Event(id: "test_id_1", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")
        let expectedItem = Item(event: expectedEvent, isFavorite: true)

        // create scheduler
        let action = scheduler.createObserver([Item].self)

        sut.output.items
            .drive(action)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(10, expectedEvent)])
            .bind(to: storage.input.swapFavoriteMark)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(action.events, [.next(0, []), .next(10, [expectedItem])], "Expected Items doesn't match")
    }

    func testSwappingFavoriteEventOutside() {
        let expectedEvent = Event(id: "test_id_1", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")
        let expectedItem = Item(event: expectedEvent, isFavorite: true)

        // create scheduler
        let action = scheduler.createObserver([Item].self)

        sut.output.items
            .drive(action)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(10, expectedEvent),
                                        .next(20, expectedEvent)])
            .bind(to: storage.input.swapFavoriteMark)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(action.events, [.next(0, []), .next(10, [expectedItem]), .next(20, [])], "Expected Items doesn't match")
    }

    func testFaforiteTap() {
        let expectedEvent = Event(id: "test_id_1", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")
        let expectedItem = Item(event: expectedEvent, isFavorite: true)

        // create scheduler
        let action = scheduler.createObserver([Item].self)

        sut.output.items
            .drive(action)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(10, expectedEvent)])
            .bind(to: storage.input.swapFavoriteMark)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(10, expectedItem)])
            .bind(to: sut.input.selectedItem)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(20, expectedEvent)])
            .bind(to: sut.input.tapFavorite)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(action.events, [.next(0, []), .next(10, [expectedItem]), .next(20, [])], "Expected Items doesn't match")
    }

    func testInitialStoreIsFilledThreeValue() {
        let expectedEventOne = Event(id: "test_id_1", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")
        let expectedEventTwo = Event(id: "test_id_2", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")
        let expectedEventThree = Event(id: "test_id_3", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")

        let expectedItemOne = Item(event: expectedEventOne, isFavorite: true)
        let expectedItemTwo = Item(event: expectedEventTwo, isFavorite: true)
        let expectedItemThree = Item(event: expectedEventThree, isFavorite: true)

        // create scheduler
        let action = scheduler.createObserver([Item].self)

        sut.output.items
            .drive(action)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([.next(10, expectedEventOne),
                                        .next(20, expectedEventTwo),
                                        .next(40, expectedEventThree)])
            .bind(to: storage.input.swapFavoriteMark)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(action.events, [.next(0, []),
                                       .next(10, [expectedItemOne]),
                                       .next(20, [expectedItemTwo, expectedItemOne]),
                                       .next(40, [expectedItemThree, expectedItemTwo, expectedItemOne])],
                       "Expected item chain doesn't match")
    }

    func testSelectionItem() {
        let expectedEvent = Event(id: "test_id_1", title: "test_title", start_time: "2019-01-12 10:05:00", url: "empty")
        let expectedItem = Item(event: expectedEvent, isFavorite: true)

        scheduler.createColdObservable([.next(10, expectedItem)])
            .bind(to: sut.input.selectedItem)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(OpenURLHelper.shared.lastURL, expectedEvent.url, "Expected URL doesn't match")
    }
}
