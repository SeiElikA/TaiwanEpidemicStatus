//
//  OpenWeekCollectionViewFlowLayout.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/13.
//

import UIKit

class OpenWeekCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        let height = collectionView!.bounds.height
        let width = collectionView!.bounds.width
        let itemSize = height
        
        self.scrollDirection = .horizontal
        self.itemSize = CGSize(width: height, height: height)
    }
}
