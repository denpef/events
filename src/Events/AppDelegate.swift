import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let serviceContainer = buildServiceContainer()

        if let tab = window?.rootViewController as? UITabBarController {
            for child in tab.viewControllers ?? [] {
                if let top = child as? Configurable {
                    top.configure(with: serviceContainer)
                }
            }
        }
        return true
    }

    /// Services container initialization
    ///
    private func buildServiceContainer() -> ServiceContainerType {
        let networkProvider = NetworkProvider()
        let api = API(networkProvider: networkProvider)
        let localStorage = LocalStorage()
        let eventService = EventService(api: api, storage: localStorage)
        return ServiceContainer(localStorage: localStorage, eventService: eventService)
    }
}
