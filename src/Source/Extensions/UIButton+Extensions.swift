import UIKit

extension UIButton {
    /// Set image withRenderingMode == alwaysTemplate and tint color
    func setImage(_ image: UIImage, tintColor: UIColor) {
        let tintableImage = image.withRenderingMode(.alwaysTemplate)
        setImage(tintableImage, for: .normal)
        self.tintColor = tintColor
    }
}
