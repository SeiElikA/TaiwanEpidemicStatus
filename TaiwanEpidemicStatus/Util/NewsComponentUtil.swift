//
//  NewsComponentUtil.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/29.
//

import Foundation
import UIKit
import WebKit

class NewsComponentUtil {
    private var viewController:UIViewController
    
    private init(viewController:UIViewController) {
        self.viewController = viewController
    }
    
    public static func getInstance(_ viewController:UIViewController) -> NewsComponentUtil {
        return NewsComponentUtil(viewController: viewController)
    }
    

}
