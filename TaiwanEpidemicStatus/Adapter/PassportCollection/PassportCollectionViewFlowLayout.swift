//
//  PassportCollectionViewFlowLayout.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/4.
//

import UIKit

class PassportCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        let width = self.collectionView!.bounds.width
        let height = self.collectionView!.bounds.height
        let padding = CGFloat(18)
        let itemWidth = width - 18 * 2

        self.itemSize = CGSize(width: itemWidth, height: height)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 20
        self.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let width = collectionView!.bounds.width
        let height = collectionView!.bounds.height
        var targetP = proposedContentOffset
        let rect = CGRect(x: targetP.x, y: 0, width: width, height: height)
        let attrs = super.layoutAttributesForElements(in: rect)
        
        var minSpace = CGFloat(MAXFLOAT)
        attrs?.forEach({ attr in
            let offsetCenter = targetP.x + (width * 0.5)
            let offsetX = attr.center.x - offsetCenter
            if abs(offsetX) < abs(minSpace) {
                minSpace = offsetX
            }
        })
        
        targetP.x += minSpace
        
        return targetP
    }
}
