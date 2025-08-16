import UIKit

extension UICollectionView {
    func deselectAllItems() {
        for indexPath in indexPathsForSelectedItems ?? [] {
            deselectItem(at: indexPath, animated: false)
        }
    }
}
