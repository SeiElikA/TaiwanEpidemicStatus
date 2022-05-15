//
//  AboutUsViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/15.
//

import UIKit

class AboutUsViewController: UIViewController {
    @IBOutlet weak var txtSeiElika: UILabel!
    @IBOutlet weak var txtSeielikaEmail: UILabel!
    @IBOutlet weak var txtSeielikaDiscord: UILabel!
    @IBOutlet weak var viewSeielika: UIView!
    @IBOutlet weak var txtKaijun: UILabel!
    @IBOutlet weak var txtKaijunEmail: UILabel!
    @IBOutlet weak var txtKaijunDiscord: UILabel!
    @IBOutlet weak var viewKaijun: UIView!
    @IBOutlet weak var txtJoinTitle: UILabel!
    @IBOutlet weak var viewJoin: UIView!
    
    @IBOutlet var txtAll: [UILabel]!
    @IBOutlet var viewAll: [UIView]!
    
    private let alertController = UIAlertController(title: NSLocalizedString("CopyDone", comment: ""), message: nil, preferredStyle: .alert)
    private var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // swipe back view controller
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        // setting style
        let label = UILabel()
        label.text = NSLocalizedString("AboutUs", comment: "")
        label.textColor = .white
        self.navigationItem.titleView = label
        
        let backButton = UIButton()
        backButton.setTitle(" Settings", for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        let backImage = UIImage(systemName: "chevron.backward")
        backButton.tintColor = .white
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(backEvent), for: .touchDown)
        
        let barButton = UIBarButtonItem()
        barButton.customView = backButton
        barButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = barButton
        
        txtAll.forEach {
            $0.font = UIFont.roundedFont($0.font.pointSize)
        }
        
        viewAll.forEach {
            $0.layer.shadowColor = UIColor(named: "MainShadowColor")?.cgColor
            $0.layer.shadowRadius = 6
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        
        txtJoinTitle.font = UIFont.roundedBoldFont(txtJoinTitle.font.pointSize)
        
        txtSeielikaEmail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendEmail(sender:))))
        txtKaijunEmail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendEmail(sender:))))
        
        txtSeielikaDiscord.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyDiscordName(sender:))))
        txtKaijunDiscord.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyDiscordName(sender:))))
    }
    
    @IBAction func btnJoinClickEvent(_ sender: Any) {
        let url = URL(string: Global.inviteDiscordURL)!
        UIApplication.shared.open(url)
    }
    
    @objc private func sendEmail(sender: UIGestureRecognizer) {
        let label = sender.view as! UILabel
        let url = URL(string: "mailto:\(label.text!)")!
        UIApplication.shared.open(url)
    }
    
    @objc private func copyDiscordName(sender: UIGestureRecognizer) {
        let label = sender.view as! UILabel
        let name = label.text
        UIPasteboard.general.string = name
        
        self.present(alertController, animated: true)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerStop), userInfo: nil, repeats: false)
    }

    @objc private func timerStop() {
        self.alertController.dismiss(animated: true)
        timer?.invalidate()
    }
    
    @objc private func backEvent() {
        self.navigationController?.popViewController(animated: true)
    }
}
