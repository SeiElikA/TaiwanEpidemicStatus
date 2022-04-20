//
//  BottomNavigationView.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import UIKit

class BottomNavigationView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private var _circleRadius:CGFloat = 0
    private var circlePadding:CGFloat = 20
    private var paddingRadius:CGFloat   = 5
    
    @IBInspectable
    var circleRadius: CGFloat {
        get {
            return _circleRadius
        }
        set {
            _circleRadius = newValue
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        var point = CGPoint(x: 0, y: 0)
        path.move(to: point)
        let screenWidth = UIScreen.main.bounds.width
        point = CGPoint(x: CGFloat((Int(screenWidth) / 2)) - paddingRadius - circlePadding, y: 0)
        path.move(to: point)
        point.y += paddingRadius
        path.addArc(withCenter: point, radius: paddingRadius, startAngle: 270, endAngle: 0, clockwise: true)
        point.x += paddingRadius
        path.move(to: point)
    }
}
