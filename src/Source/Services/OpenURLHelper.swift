import UIKit

/// Responsible for opening links in the browser
/// made according to the singleton template since it is necessary to store the data of the last link for testing
final class OpenURLHelper {
    static let shared = OpenURLHelper()

    /// Store the data of the last link for testing
    var lastURL: String?

    private init() {}

    /// Open URL in browser
    /// - Parameter path: Full URL path
    func openLink(by path: String) {
        lastURL = path
        guard let url = URL(string: path) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
