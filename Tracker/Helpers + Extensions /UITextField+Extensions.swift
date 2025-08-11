import UIKit


extension UITextField {
    func addPaddingToTextField() {
        let paddingView : UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
