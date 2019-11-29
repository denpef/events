import UIKit

/// Event info for displaing in TableViewCell
struct Item {
    let event: Event
    let isFavorite: Bool
    var image: UIImage {
        if isFavorite {
            return Asset.starFilled.image
        } else {
            return Asset.starEmpty.image
        }
    }
}

extension Item: Equatable {}
