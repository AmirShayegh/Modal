//
//  ModalListView.swift
//  MyRangeBCManager
//
//  Created by Amir Shayegh on 2019-04-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ModalListView: ModalView {
    
    var options: [String] = [String]()
    
    var cancelCallback: (()-> Void)?
    var selectCallBack: ((_ option: String)-> Void)?
    
    let width: CGFloat = 270
    let height: CGFloat = 400
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var titleBarHeight: NSLayoutConstraint!
    @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
    
    @IBAction func cancelAction(_ sender: UIButton) {
        if let cancelCallback = self.cancelCallback {
            remove()
            return cancelCallback()
        } else {
            remove()
        }
    }
    
    func returnResult(option: String) {
        if let selectCallBack = self.selectCallBack {
            remove()
            return selectCallBack(option)
        } else {
            remove()
        }
    }
    
    func initialize(title: String, options: [String], cancelCallback: @escaping()-> Void, selectCallBack: @escaping(_ option: String)-> Void) {
        self.cancelCallback = cancelCallback
        self.selectCallBack = selectCallBack
        self.titleLabel.text = title
        self.options = options
        setupTableView()
        setFixed(width: width, height: height)
        style()
        present()
    }
    
    func style() {
        addShadow(to: self.layer, opacity: 0.8, height: 2)
        self.layer.cornerRadius = 5
        titleLabel.font = ModalList.titleFont
        titleLabel.textColor = ModalList.titleColor
        self.cancelButton.setTitle("", for: .normal)
        if let icon = UIImage(named: "close", in: ModalList.bundle, compatibleWith: nil) {
            self.cancelButton.setImage(icon, for: .normal)
            if let buttonImage = cancelButton.imageView {
                buttonImage.contentMode = .scaleAspectFit
                cancelButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            }
            cancelButton.tintColor = ModalList.closeButtonColor
        } else {
            self.cancelButton.setTitle("Close", for: .normal)
        }
        divider.backgroundColor = ModalList.dividerColor
        self.titleBarHeight.constant = ModalList.titleBarHeight
        self.closeButtonHeight.constant = calc(percent: 70, of:  ModalList.titleBarHeight)
    }
    
    func calc(percent: CGFloat, of: CGFloat)-> CGFloat {
        return ((of * percent) / 100)
    }
    
    func addShadow(to layer: CALayer, opacity: Float, height: Int, radius: CGFloat? = 10) {
        layer.borderColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 10
    }
}
extension ModalListView: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        register(cell: "ModalListItemTableViewCell")
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: ModalList.bundle)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getItemCell(indexPath: IndexPath) -> ModalListItemTableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "ModalListItemTableViewCell", for: indexPath) as! ModalListItemTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getItemCell(indexPath: indexPath)
        cell.initialize(option: options[indexPath.row], selectCallBack: {
            self.returnResult(option: self.options[indexPath.row])
        })
        return cell
    }
    
}
