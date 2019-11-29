import UIKit

final class OpenURLHelper {
    static let shared = OpenURLHelper()

    var lastURL: String?

    private init() {}

    func openLink(by path: String) {
        lastURL = path
        guard let url = URL(string: path) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
