
import Foundation
import UIKit

extension UICollectionViewCell {
    
    static var nib: UINib {
        return UINib(nibName: self.className, bundle: nil)
    }
}

extension UICollectionReusableView {
    
    static var nib1: UINib {
        return UINib(nibName: self.className, bundle: nil)
    }
}
