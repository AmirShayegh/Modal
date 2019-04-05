//
//  ModalListItemTableViewCell.swift
//  MyRangeBCManager
//
//  Created by Amir Shayegh on 2019-04-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ModalListItemTableViewCell: UITableViewCell {
    
    var selectCallBack: (()-> Void)?

    @IBOutlet weak var optionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initialize(option: String, selectCallBack: @escaping()-> Void) {
        self.selectCallBack = selectCallBack
        self.optionLabel.text = option
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (self.onTap (_:)))
        self.addGestureRecognizer(tapGesture)
        style()
    }
    
    @objc func onTap(_ sender:UITapGestureRecognizer){
        if let selectCallBack = selectCallBack {
            return selectCallBack()
        }
    }
    
    func style() {
        optionLabel.font = ModalList.optionFont
        optionLabel.textColor = ModalList.optionColor
    }
    
}
