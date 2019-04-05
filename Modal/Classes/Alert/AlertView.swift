//
//  Alert.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-03.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

enum AlertMode {
    case YesNo
    case Custom
    case Message
}

class AlertView: ModalView {
    // MARK: Variables
    var rightButtonCallback: (()-> Void)?
    var leftButtonCallBack: (()-> Void)?
    var mode: AlertMode?
    
    var customRightButtonName: String = ""
    var customLeftButtonName: String = ""
    
    var titleFont = ModalAlert.titleFont
    var messageFont = ModalAlert.messageFont
    var buttonFont = ModalAlert.buttonFont
    
    let verticalContentPadding: CGFloat = 60
    let paddingBetweenTitleAndMessage: CGFloat = 8
    let horizontalContentPadding: CGFloat = 36
    let buttonHeightConst: CGFloat = 43
    
    let width: CGFloat = 270

    // MARK: Outlets
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var buttonsContainer: UIView!

    // Padding
    @IBOutlet weak var titleTopPadding: NSLayoutConstraint!
    @IBOutlet weak var messageTopPadding: NSLayoutConstraint!
    @IBOutlet weak var buttonsTopPadding: NSLayoutConstraint!
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!

    // MARK: Outlet Actions
    @IBAction func leftButtonAction(_ sender: Any) {
        if let callback = self.leftButtonCallBack {
            self.remove()
            return callback()
        }
    }

    @IBAction func rightButtonAction(_ sender: Any) {
        if let callback = self.rightButtonCallback {
            self.remove()
            return callback()
        }
    }
    
    // MARK: Initialization
    func initialize(mode: AlertMode, title: String, message: String, leftButtonName: String = "", rightButtonName: String = "",rightButtonCallback: @escaping()-> Void, leftButtonCallBack: @escaping()-> Void) {
        setFixed(width: width, height: estimateHeightWith(title: title, message: message))
        self.mode = mode
        if mode == .Custom {
            customRightButtonName = rightButtonName
            customLeftButtonName = leftButtonName
        }
        self.rightButtonCallback = rightButtonCallback
        self.leftButtonCallBack = leftButtonCallBack
        fill(title: title, message: message)
        present()
        style()
    }

    // MARK: Autofill
    func fill(title: String, message: String) {
        self.title.text = title
        self.message.text = message
        self.adjustSizes(title: title)
    }
    
    // MARK: Dynamic Height
    private func estimateHeightWith(title: String, message: String) -> CGFloat {
        
        // This adds extra padding between message and the buttons
        let extraPadding: CGFloat = 8
        
        var h: CGFloat = 0
        h = title.height(withConstrainedWidth: width - horizontalContentPadding, font: titleFont)
        h += message.height(withConstrainedWidth: width - horizontalContentPadding, font: messageFont)
        h += buttonHeightConst
        h += verticalContentPadding
        h += extraPadding
        return h
    }

    func adjustSizes(title: String) {
        self.buttonHeight.constant = buttonHeightConst
        self.titleHeight.constant = title.height(withConstrainedWidth: width - horizontalContentPadding, font: titleFont)
        messageTopPadding.constant = paddingBetweenTitleAndMessage
        let remainingTopPadding = verticalContentPadding - paddingBetweenTitleAndMessage
        titleTopPadding.constant = remainingTopPadding / 2
        buttonsTopPadding.constant = remainingTopPadding / 2
        leftPadding.constant = horizontalContentPadding / 2
        rightPadding.constant = horizontalContentPadding / 2
    }

    // MARK: Style
    func style() {
        guard let mode = self.mode else {return}
        addShadow(to: self.layer, opacity: 0.8, height: 2)
        self.layer.cornerRadius = 5
        self.buttonsContainer.backgroundColor = ModalAlert.buttonAccentColor
        self.title.font = titleFont
        self.message.font = messageFont
        if let leftLabel = leftButton.titleLabel, let rightLabel = rightButton.titleLabel {
            leftLabel.font = buttonFont
            rightLabel.font = buttonFont
        }
        self.leftButton.setTitleColor(ModalAlert.primaryColor, for: .normal)
        self.rightButton.setTitleColor(ModalAlert.primaryColor, for: .normal)
        switch mode {
        case .YesNo:
            self.leftButton.setTitle("No", for: .normal)
            self.rightButton.setTitle("Yes", for: .normal)
        case .Message:
            self.leftButton.isHidden = true
            self.rightButton.setTitle("Okay", for: .normal)
        case .Custom:
            self.leftButton.setTitle(customLeftButtonName, for: .normal)
            self.rightButton.setTitle(customRightButtonName, for: .normal)
        }

    }
    
    public func addShadow(to layer: CALayer, opacity: Float, height: Int, radius: CGFloat? = 10) {
        layer.borderColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 10
    }

}
