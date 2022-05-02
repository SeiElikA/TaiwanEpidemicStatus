//
//  AllNewsCollectionViewFlowLayout.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/1.
//

import UIKit

class AllNewsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        let height = collectionView!.bounds.height
        let width = collectionView!.bounds.width
        
        let topPadding = CGFloat(12)
        let bottomPadding = CGFloat(0)
        
        let itemSizeHeight = height
        let itemSizeWidth = itemSizeHeight * 1.3
        self.itemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = -10

        let insertHorizontal = (width - itemSizeWidth) / 2
        self.sectionInset = UIEdgeInsets(top: topPadding, left: insertHorizontal, bottom: bottomPadding, right: insertHorizontal)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let width = collectionView!.bounds.width
        let height = collectionView!.bounds.height
        var targetP = proposedContentOffset
        
        let rect = CGRect(x: targetP.x, y: 0, width: width, height: height)
        let attrs = super.layoutAttributesForElements(in: rect)
        var minSpace = CGFloat(MAXFLOAT)
        attrs?.forEach({
            let offsetCenter = targetP.x + width / 2
            let offsetX = $0.center.x - offsetCenter
            if abs(offsetX) < abs(minSpace) {
                minSpace = offsetX
            }
        })
        
        targetP.x += minSpace
        return targetP
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let width = self.collectionView!.bounds.width
        let attrs = super.layoutAttributesForElements(in: rect)
        let centerOffset = collectionView!.contentOffset.x + width / 2
        attrs?.forEach({
            let position = ($0.center.x - centerOffset) / width
            let scale = 1 - abs(position) * (1 - 0.7)
            let alpha = 1 - abs(position) * (1 - 0.4)
            $0.transform = CGAffineTransform(scaleX: scale, y: scale)
            $0.alpha = alpha
        })
        
        return attrs  
    }
}