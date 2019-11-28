import UIKit

enum OpenURLHelper {
    static func openLink(by path: String) {
        guard let url = URL(string: path) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
