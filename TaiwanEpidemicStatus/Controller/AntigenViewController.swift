//
//  AntigenViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/13.
//

import UIKit

class AntigenViewController: UIViewController, BaseAntigenViewController {
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
        
        // binding data
        self.txtAddress.text = antigenData?.address
        self.txtHospitalName.text = antigenData?.name
        self.txtUpdateTime.text! += antigenData?.updated_at.replace("/", ".") ?? "Error"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        completion?()
    }
}

extension AntigenViewController: UITableViewDataSource, UITableViewDelegate {
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

extension AntigenViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
