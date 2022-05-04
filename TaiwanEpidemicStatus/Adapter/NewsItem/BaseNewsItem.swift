//
//  BaseNewsItem.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/3.
//

import Foundation
import UIKit

public protocol BaseNewsItem: UITableViewCell {
    var shareLink:String? {get set}
    var viewController:UIViewController? {get set}
    var viewBackground: UIView! {get set}
    var btnShare: UIButton! {get set}
    var imgNews: UIImageView! {get set}
    var txtCaption: UILabel! {get set}
    var txtDate: UILabel! {get set}
    var txtTitle: UILabel! {get set}
    var activityIndicator:UIActivityIndicatorView! {get set}
}
