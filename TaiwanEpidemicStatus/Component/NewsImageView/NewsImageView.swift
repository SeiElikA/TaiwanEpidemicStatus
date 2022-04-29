//
//  NewsImageView.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/29.
//

import UIKit

class NewsImageView: UIView {
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsCaption: UILabel!
    @IBOutlet weak var loadImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var root: UIView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
}

fileprivate extension NewsImageView {
    func setup() {
        Bundle.main.loadNibNamed("NewsImageView", owner: self, options: nil)
        addSubview(root)
        root.frame = self.bounds
        root.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
