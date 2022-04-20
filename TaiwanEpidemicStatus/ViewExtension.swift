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
