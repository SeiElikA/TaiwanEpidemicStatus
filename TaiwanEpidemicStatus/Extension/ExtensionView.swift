//
//  ViewExtension.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import Foundation
import UIKit

extension UIFont {
    static func roundedBoldFont(_ fontSize:CGFloat) -> UIFont {
        if let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded) {
            let test = fontDescriptor.withSymbolicTraits(.traitBold)
            let font = UIFont(descriptor: test!, size: fontSize)
            return font
        }
        return UIFont.systemFont(ofSize:fontSize)
    }
    
    static func roundedFont(_ fontSize:CGFloat) -> UIFont {
        if let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded) {
            let font = UIFont(descriptor: fontDescriptor, size: fontSize)
            return font
        }
        return UIFont.systemFont(ofSize:fontSize)
    }
}

extension UIViewController {
    func showServerNotRunningAlert() {
        let serverErrorMsg = NSLocalizedString("ServerError", comment: "")
        let alertController = UIAlertController(title: "Error", message: serverErrorMsg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
}

extension UIView {
    func fadeInAnimate(during:Double, completion:(() -> Void)? = nil) {
        self.alpha = 0
        UIView.animate(withDuration: during, delay: 0, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }
    
    func fadeOutAnimate(during:Double, completion:(() -> Void)? = nil) {
        self.alpha = 1
        UIView.animate(withDuration: during, delay: 0, animations: {
            self.alpha = 0
        }, completion: { _ in
            completion?()
        })
    }
}
