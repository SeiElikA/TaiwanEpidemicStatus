//
//  PassportViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/3.
//

import UIKit
import AudioToolbox

class PassportViewController: UIViewController {
    @IBOutlet weak var passportCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private lazy var coreDataModel = PassportEntityModel(context: context)
    public static var instance:PassportViewController?
    private var passportData:[PassportEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PassportViewController.instance = self
        
        passportCollection.decelerationRate = UIScrollView.DecelerationRate.init(rawValue: 0.95)
        passportCollection.dataSource = self
        passportCollection.delegate = self
        passportCollection.register(UINib(nibName: PassportCollectionViewCell.identity, bundle: nil), forCellWithReuseIdentifier: PassportCollectionViewCell.identity)
        
        reloadPassportData()
    }
    
    @IBAction func btnBackEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnScanQRCode(_ sender: Any) {
        let scanViewController = ScanQRCodeViewController()
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }
    
    @IBAction func pageControlEvent(_ sender: Any) {
        let index = pageControl.currentPage
        passportCollection.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    public func reloadPassportData() {
        self.passportData = coreDataModel.getAllPassport()
        self.passportCollection.reloadData()
    }
}

extension PassportViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PassportCollectionViewCell.identity, for: indexPath) as! PassportCollectionViewCell
        let data = passportData[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        cell.txtIssuedBy.text = data.country
        cell.txtName.text = data.name
        cell.txtVaccine.text = data.vaccine
        cell.txtDate.text = formatter.string(from: data.vaccineDate ?? Date())
        cell.txtVaccineCount.text = NSLocalizedString("PassportDoses", comment: "").replace("{currentNumber}", "\(data.dose)").replace("{totalNumber}", "\(data.doses)")
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(deleteEvent(_:))))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = passportData.count
        return passportData.count
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
    
    @objc private func deleteEvent(_ view: UIGestureRecognizer) {
        let cgRect = CGRect(origin: self.passportCollection.contentOffset, size: self.passportCollection.bounds.size)
        let cgPoint = CGPoint(x: cgRect.midX, y: cgRect.midY)
        let index = self.passportCollection.indexPathForItem(at: cgPoint)?.row ?? 0
        
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
            view.view?.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
        animator.startAnimation()
        AudioServicesPlaySystemSound(1519)
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                view.view?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            animator.startAnimation()
        })
        
        let alertDelete = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let data = self.passportData[index]
            UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: {
                view.view?.alpha = 0
            }).startAnimation()
            self.coreDataModel.deletePassport(id: data.id)
            self.reloadPassportData()
        })
        
        alertController.addAction(alertCancel)
        alertController.addAction(alertDelete)
        self.present(alertController, animated: true)
    
    }
}
