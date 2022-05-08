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
    @IBOutlet weak var txtPlaceHolder: UILabel!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    
    private var placeHolderClickCount = 0
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private lazy var coreDataModel = PassportEntityModel(context: context)
    public static var instance:PassportViewController?
    private var passportData:[PassportEntity] = []
    private var cellIdentity:[IndexPath:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PassportViewController.instance = self
        
        passportCollection.decelerationRate = UIScrollView.DecelerationRate.init(rawValue: 0.95)
        passportCollection.dataSource = self
        passportCollection.delegate = self
        passportCollection.register(UINib(nibName: PassportCollectionViewCell.identity, bundle: nil), forCellWithReuseIdentifier: PassportCollectionViewCell.identity)
        
        imgPlaceHolder.isUserInteractionEnabled = true
        imgPlaceHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgPlaceHolderClickEvent)))
        reloadPassportData()
    }
    
    @objc private func imgPlaceHolderClickEvent() {
        placeHolderClickCount += 1
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        var animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
            self.imgPlaceHolder.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        })
        animator.startAnimation()
        animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
            self.imgPlaceHolder.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        animator.startAnimation()
        
        if placeHolderClickCount == 5 {
            placeHolderClickCount = 0
            self.showHelperMenu()
        }
    }
    
    private func showHelperMenu() {
        let questionTitle = NSLocalizedString("HaveQuestion", comment: "")
        let applyText = NSLocalizedString("ApplyVaccination", comment: "")
        let questionAndAnsText = NSLocalizedString("AboutVaccination", comment: "")
        let operationtext = NSLocalizedString("OperationManualVaccination", comment: "")
        
        let alertController = UIAlertController(title: questionTitle, message: nil, preferredStyle: .actionSheet)
        
        let applyAction = UIAlertAction(title: applyText, style: .default) { _ in
            self.openWebSite(url: "https://dvc.mohw.gov.tw/")
        }
        let operationAction = UIAlertAction(title: operationtext, style: .default) { _ in
            self.openWebSite(url: "https://dvc.mohw.gov.tw/vapa/template/vapa/common/pdf/OperationsManual.pdf")
        }
        let questionAction = UIAlertAction(title: questionAndAnsText, style: .default) { _ in
            self.openWebSite(url: "https://dvc.mohw.gov.tw/vapa/template/vapa/common/pdf/QA.pdf")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(applyAction)
        alertController.addAction(operationAction)
        alertController.addAction(questionAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    private func openWebSite(url:String) {
        let url = URL(string: url)!
        UIApplication.shared.open(url)
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
        self.checkIsShowPlaceHolder()
    }
    
    public func checkIsShowPlaceHolder() {
        self.txtPlaceHolder.isHidden = !self.passportData.isEmpty
        if self.passportData.isEmpty {
            self.imgPlaceHolder.alpha = 0
            self.imgPlaceHolder.frame = self.imgPlaceHolder.frame.offsetBy(dx: 0, dy: 150)
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
                self.imgPlaceHolder.alpha = 1
                self.imgPlaceHolder.frame = self.imgPlaceHolder.frame.offsetBy(dx: 0, dy: -150)
            })
            animator.startAnimation()
        }
        
        self.imgPlaceHolder.isHidden = !self.passportData.isEmpty
        self.passportCollection.isHidden = self.passportData.isEmpty
    }
}

extension PassportViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identitier = cellIdentity[indexPath]
        if identitier == nil {
            identitier = UUID().uuidString
            cellIdentity[indexPath] = identitier
            self.passportCollection.register(UINib(nibName: PassportCollectionViewCell.identity, bundle: nil), forCellWithReuseIdentifier: identitier!)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identitier!, for: indexPath) as! PassportCollectionViewCell
        let data = passportData[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
    
        cell.txtIssuedBy.text = data.country
        cell.txtName.text = data.name
        cell.txtVaccine.text = data.vaccine
        cell.txtDate.text = formatter.string(from: data.vaccineDate ?? Date())
        cell.txtVaccineCount.text = NSLocalizedString("PassportDoses", comment: "").replace("{currentNumber}", "\(data.dose)").replace("{totalNumber}", "\(data.doses)")
        cell.imgQRCode.image = QRCodeUtil.generateQRCode(data.hc1Code ?? "") 
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
    
    @objc private func deleteEvent(_ view: UILongPressGestureRecognizer) {
        if view.state != .began {
            return
        }
        
        let cgRect = CGRect(origin: self.passportCollection.contentOffset, size: self.passportCollection.bounds.size)
        let cgPoint = CGPoint(x: cgRect.midX, y: cgRect.midY)
        let index = self.passportCollection.indexPathForItem(at: cgPoint)?.row ?? 0
        
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            view.view?.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
        animator.startAnimation()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
                view.view?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            animator.startAnimation()
        })
        
        let alertDelete = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.passportCollection.performBatchUpdates({
                let id = self.passportData[index].id
                self.passportData.remove(at: index)
                self.passportCollection.deleteItems(at: [IndexPath(row: index, section: 0)])
                self.passportCollection.collectionViewLayout.invalidateLayout()
                self.coreDataModel.deletePassport(id: id)
            })

            self.reloadPassportData()
        })
        
        alertController.addAction(alertCancel)
        alertController.addAction(alertDelete)
        self.present(alertController, animated: true)
    }
}
