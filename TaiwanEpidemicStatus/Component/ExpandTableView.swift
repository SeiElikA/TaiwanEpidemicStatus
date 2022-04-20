//
//  ExpandTableView.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import Foundation
import UIKit

public class ExpandTableView: UITableView {
    public override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
