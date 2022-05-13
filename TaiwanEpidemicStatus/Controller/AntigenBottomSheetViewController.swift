//
//  AntigenBottomSheetViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/12.
//

import UIKit

class AntigenBottomSheetViewController: UIViewController, UIScrollViewDelegate, BaseAntigenViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var touchView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var touchStackView: UIStackView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var openWeekCollectionView: UICollectionView!
    @IBOutlet weak var brandsTableView: ExpandTableView!
    @IBOutlet weak var detailTableView: ExpandTableView!
    @IBOutlet weak var txtUpdateTime: UILabel!
    @IBOutlet weak var txtHospitalName: UILabel!
    @IBOutlet weak var txtAddress: UILabel!
    
    // Data
    public var antigenData:Properties?
    public var completion:(() -> Void)?
    private var maxHeight = UIScreen.main.bounds.height - 64
    private lazy var screenHeight = UIScreen.main.bounds.height
    private lazy var defaultHeight = screenHeight * 0.4
    private lazy var dismissHeight = defaultHeight * 0.6
    private var mainViewHeightConstraint:NSLayoutConstraint?
    private var mainViewBottomConstraint:NSLayoutConstraint?
    private var currentConstraintHeight = 0.0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.currentConstraintHeight = self.defaultHeight
        
        self.setViewAppearAnimator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set ScrollView
        self.contentScrollView.delegate = self
        
        // set brands Table View
        self.brandsTableView.dataSource = self
        self.brandsTableView.delegate = self
        self.brandsTableView.register(UINib(nibName: SelectCityTableViewCell.identity, bundle: nil), forCellReuseIdentifier: SelectCityTableViewCell.identity)
        
        // set open week Collection View
        self.openWeekCollectionView.dataSource = self
        self.openWeekCollectionView.delegate = self
        self.openWeekCollectionView.register(UINib(nibName: OpenWeekCollectionViewCell.identity, bundle: nil    ), forCellWithReuseIdentifier: OpenWeekCollectionViewCell.identity)
        
        // set detail Table View
        self.detailTableView.dataSource = self
        self.detailTableView.delegate = self
        self.detailTableView.register(UINib(nibName: DetailTableViewCell.identity, bundle: nil), forCellReuseIdentifier: DetailTableViewCell.identity)
        
        // set view
        self.setViewStyle()
        self.setViewConstraint()
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateDismissView)))
        self.setPanGesture()
        
        // binding data
        self.txtAddress.text = antigenData?.address
        self.txtHospitalName.text = antigenData?.name
        self.txtUpdateTime.text! += antigenData?.updated_at.replace("/", ".") ?? "Error"
    }
    
    private func setViewStyle() {
        mainView.layer.cornerRadius = 8
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainView.clipsToBounds = true
        
        touchView.layer.cornerRadius = touchView.frame.height / 2
    }
    
    private func setViewConstraint() {
        self.mainView.translatesAutoresizingMaskIntoConstraints = false
        
        self.mainViewHeightConstraint =  mainView.heightAnchor.constraint(equalToConstant: defaultHeight)
        self.mainViewBottomConstraint = mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        
        self.mainViewHeightConstraint?.isActive = true
        self.mainViewBottomConstraint?.isActive = true
    }
    
    private func setViewAppearAnimator() {
        UIView.animate(withDuration: 0.3) {
            self.mainViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func animateDismissView() {
        let animatorBackgroundView = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            self.backgroundView.alpha = 1
        })
        
        let animatorView = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations:{
            self.mainViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: true)
            self.completion?()
        })
        
        animatorBackgroundView.startAnimation()
        animatorView.startAnimation()
    }
    
    private func setPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePenGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func animationContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, animations: {
            self.mainViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        })

        self.currentConstraintHeight = height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50 {
            self.animationContainerHeight(defaultHeight)
            self.contentScrollView.isScrollEnabled = false
        }
    }
    
    @objc private func handlePenGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        let isDraggingDown = translation.y > 0
        let newHeight = currentConstraintHeight - translation.y
        
        switch gesture.state {
        case .changed:
            if newHeight < maxHeight {
                self.mainViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
            
        case .ended:
            if newHeight < dismissHeight {
                self.animateDismissView()
            } else if newHeight < defaultHeight {
                self.animationContainerHeight(defaultHeight)
                self.contentScrollView.isScrollEnabled = false
            } else if newHeight > UIScreen.main.bounds.height * 0.75 && isDraggingDown {
                self.animationContainerHeight(maxHeight)
                self.contentScrollView.isScrollEnabled = true
            } else if newHeight < maxHeight && isDraggingDown {
                self.animationContainerHeight(defaultHeight)
                self.contentScrollView.isScrollEnabled = false
            } else if newHeight < UIScreen.main.bounds.height / 2 && !isDraggingDown {
                self.animationContainerHeight(defaultHeight)
                self.contentScrollView.isScrollEnabled = false
            } else if newHeight > defaultHeight && !isDraggingDown {
                self.animationContainerHeight(maxHeight)
                self.contentScrollView.isScrollEnabled = true
            }
        default:
            break
        }
    }
}

extension AntigenBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return self.antigenData?.note == nil ? 2 : 3
        }
        
        return antigenData?.brands.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identity, for: indexPath) as! DetailTableViewCell
            if indexPath.row == 0 {
                cell.txtSubTitle.text = NSLocalizedString("remainAntigen", comment: "")
                let count = self.antigenData?.count ?? 0
                
                if count > 50 {
                    cell.txtTitle.textColor = .systemGreen
                } else if count > 10 {
                    cell.txtTitle.textColor = .systemYellow
                } else {
                    cell.txtTitle.textColor = .systemRed
                }
                cell.txtTitle.font = UIFont.systemFont(ofSize: 32)
                cell.txtTitle.text = "\(count)"
            } else if indexPath.row == 1 {
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phoneClickEvent)))
                cell.txtSubTitle.text = NSLocalizedString("phone", comment: "")
                cell.txtTitle.text = self.antigenData?.phone
            } else {
                cell.txtSubTitle.text = NSLocalizedString("note", comment: "")
                cell.txtTitle.text = self.antigenData?.note
                cell.txtTitle.textColor = UIColor(named: "MainShadowColor")
            }
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCityTableViewCell.identity, for: indexPath) as! SelectCityTableViewCell
        cell.txtTitle.text = antigenData?.brands[0]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    @objc private func phoneClickEvent() {
        let url = URL(string: "tel://" + self.antigenData!.phone)!
        UIApplication.shared.openURL(url)
    }
}

extension AntigenBottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OpenWeekCollectionViewCell.identity, for: indexPath) as! OpenWeekCollectionViewCell
        let dayArray:[Day] = [
            antigenData!.open_week!.monday,
            antigenData!.open_week!.tuesday,
            antigenData!.open_week!.wednesday,
            antigenData!.open_week!.thursday,
            antigenData!.open_week!.friday,
            antigenData!.open_week!.saturday,
            antigenData!.open_week!.sunday
        ]
        
        let dayNameArray = [
            "monday",
            "tuesday",
            "wednesday",
            "thursday",
            "friday",
            "saturday",
            "sunday"
        ]
        
        let data = dayArray[indexPath.row]
        let name = dayNameArray[indexPath.row]
        cell.txtWeekDay.text = NSLocalizedString(name, comment:"")
        
        cell.imgMorning.image = UIImage(systemName: data.morning ? "checkmark" : "xmark")
        cell.imgMorning.tintColor = data.morning ? .systemGreen : .systemRed
        
        cell.imgAfternoon.image = UIImage(systemName: data.afternoon ? "checkmark" : "xmark")
        cell.imgAfternoon.tintColor = data.afternoon ? .systemGreen : .systemRed
        
        cell.imgEvent.image = UIImage(systemName: data.evening ? "checkmark" : "xmark")
        cell.imgEvent.tintColor = data.evening ? .systemGreen : .systemRed
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
}
