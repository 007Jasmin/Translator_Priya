

import Foundation
import UIKit

extension UITableViewCell {
    
    static var nib: UINib {
        return UINib(nibName: self.className, bundle: nil)
    }
}
