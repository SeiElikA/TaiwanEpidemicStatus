//
//  QRCoreUtil.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/7.
//

import Foundation
import UIKit
class QRCodeUtil {
    public static func generateQRCode(_ content:String) -> UIImage? {
        let data = content.data(using: .ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    public static func decodeQRCode(_ image:UIImage) -> String {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        let ciImage = CIImage(image: image)!
        let features = detector.features(in: ciImage) as! [CIQRCodeFeature]
        return features.first?.messageString ?? ""
    }
}
