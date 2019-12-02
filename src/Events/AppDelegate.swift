import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return true
        }
        
        let serviceContainer = buildServiceContainer()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarViewController = storyboard.instantiateViewController(withIdentifier: "tabBarViewController")
        
        if let tab = tabBarViewController as? UITabBarController {
            for child in tab.viewControllers ?? [] {
                if let top = child as? Configurable {
                    top.configure(with: serviceContainer)
                }
            }
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarViewController
        window?.makeKeyAndVisible()
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
