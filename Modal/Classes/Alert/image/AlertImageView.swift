//
//  AlertImageView.swift
//  lottie-ios
//
//  Created by Amir Shayegh on 2019-04-15.
//

import Foundation

class AlertImageView: ModalView {
    
    // MARK: Variables
    var rightButtonCallback: (()-> Void)?
    var leftButtonCallBack: (()-> Void)?
    
    var customRightButtonName: String = ""
    var customLeftButtonName: String = ""
    
    var titleFont = ModalAlert.titleFont
    var buttonFont = ModalAlert.buttonFont
    
    var displayPadding: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 100
        } else {
            return 0
        }
    }
    
    let buttonHeightConst: CGFloat = 43
    let imagePreviewHeight: CGFloat = 300
    let width: CGFloat = 270
    
    // MARK: Outlets\
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var leftButton: UIButton!
    // Padding
    @IBOutlet weak var titleBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var titleTopPadding: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
 
    @IBAction func leftButtonAction(_ sender: UIButton) {
        self.imageView.image = nil
        remove()
        if let leftCallback = self.leftButtonCallBack {
            return leftCallback()
        }
    }
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        self.imageView.image = nil
        remove()
        if let rightCallback = self.rightButtonCallback {
            return rightCallback()
        }
    }
    
    // MARK: Initialization
    func initialize(title: String, image: UIImage, leftButtonName: String = "No", rightButtonName: String = "Yes",rightButtonCallback: @escaping()-> Void, leftButtonCallBack: @escaping()-> Void) {
        setFixed(width: width, height: estimateHeightWith(title: title, image: image))
        self.leftButton.setTitle(leftButtonName, for: .normal)
        self.rightButton.setTitle(rightButtonName, for: .normal)
        self.rightButtonCallback = rightButtonCallback
        self.leftButtonCallBack = leftButtonCallBack
        fill(title: title, image: image)
        present()
        style()
    }
    
    // MARK: Autofill
    func fill(title: String, image: UIImage) {
        self.titleLabel.text = title
        self.imageView.image = image
        self.adjustSizes(title: title)
    }
    
    private func estimateHeightWith(title: String, image: UIImage) -> CGFloat {
        let extraPadding: CGFloat = 32
        var h: CGFloat = 0
        h = title.height(withConstrainedWidth: width, font: titleFont)
        h += titleTopPadding.constant
        h += imagePreviewHeight
        h += buttonHeightConst
        h += titleBottomPadding.constant
        h += extraPadding
        return h
    }
    
    func getFrame(for size: CGSize) -> CGRect {
        self.layoutIfNeeded()
        let addedTopBarHeight = Modal.dividerHeight + Modal.titleBarHeight
        if size.width > size.height {
            //landscape
            let basicHeight = size.height - displayPadding
            let width = (basicHeight * 4) / 3
            let addedTopBarHeight = Modal.dividerHeight + Modal.titleBarHeight
            return CGRect(x: 0, y: 0, width: width, height: basicHeight + addedTopBarHeight)
        } else {
            //portrait
            let width =  size.width - displayPadding
            let height = (width * 4) / 3
            return CGRect(x: 0, y: 0, width: width, height: height + addedTopBarHeight)
        }
    }
    
    func adjustSizes(title: String) {
        self.buttonHeight.constant = buttonHeightConst
        self.titleHeight.constant = title.height(withConstrainedWidth: width, font: titleFont)
    }
    
    func style() {
        addShadow(to: self.layer, opacity: 0.8, height: 2)
        self.layer.cornerRadius = 5
        self.buttonContainer.backgroundColor = ModalAlert.buttonAccentColor
        self.titleLabel.font = titleFont
        if let leftLabel = leftButton.titleLabel, let rightLabel = rightButton.titleLabel {
            leftLabel.font = buttonFont
            rightLabel.font = buttonFont
        }
        self.leftButton.setTitleColor(ModalAlert.primaryColor, for: .normal)
        self.rightButton.setTitleColor(ModalAlert.primaryColor, for: .normal)
    }

}
