//
//  ExtensionMethod.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/26.
//

import Foundation
import UIKit

extension String{
    func replace(_ of:String, _ with:String) -> String {
        return self.replacingOccurrences(of: of, with: with)
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
