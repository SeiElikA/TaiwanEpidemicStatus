//
//  BaseAntigenViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/13.
//

import Foundation
import UIKit

protocol BaseAntigenViewController: UIViewController {
    var antigenData:Properties? {get set}
    var completion:(() -> Void)? {get set}
}
