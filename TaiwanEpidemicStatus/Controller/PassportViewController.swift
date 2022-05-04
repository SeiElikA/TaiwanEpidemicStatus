//
//  PassportViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/3.
//

import UIKit

class PassportViewController: UIViewController {
    @IBOutlet weak var passportCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passportCollection.dataSource = self
        passportCollection.delegate = self
        passportCollection.register(UINib(nibName: PassportCollectionViewCell.identity, bundle: nil), forCellWithReuseIdentifier: PassportCollectionViewCell.identity)
    }
    
    @IBAction func btnBackEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnScanQRCode(_ sender: Any) {
        let scanViewController = ScanQRCodeViewController()
        scanViewController.scanResult = { result in
            
            print(result)
        }
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }
    
    @IBAction func pageControlEvent(_ sender: Any) {
        let index = pageControl.currentPage
        passportCollection.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension PassportViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PassportCollectionViewCell.identity, for: indexPath) as! PassportCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // Scroll Linstener
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !(scrollView.isTracking || scrollView.isDecelerating) || scrollView != self.passportCollection {
            return
        }
        
        let width = self.passportCollection.frame.width
        let height = self.passportCollection.frame.height
        let offset = self.passportCollection.contentOffset.x
        
        let cgRect = CGRect(x: offset, y: 0, width: width, height: height)
        let cgPoint = CGPoint(x: cgRect.midX, y: cgRect.midY)
        let indexPath = self.passportCollection.indexPathForItem(at: cgPoint)
        self.pageControl.currentPage = indexPath?.row ?? 0
        return
    }
}
