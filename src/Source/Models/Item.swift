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

extension Item: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.event < rhs.event
    }
}

extension Item: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.event == rhs.event
    }
}
