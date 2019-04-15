//
//  ResultDialog.swift
//  lottie-ios
//
//  Created by Amir Shayegh on 2019-04-13.
//

import UIKit

class AlertImageDialog: UIView {
    static let buttonBarHeight: CGFloat = 51
    var completion: ((_ accepted: Bool)-> Void)?
    
    @IBOutlet weak var buttonContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var buttonsContainer: UIView!
    
    @IBAction func retryAction(_ sender: Any) {
        if let completion = self.completion {
            return completion(false)
        }
    }
    
    @IBAction func approveAction(_ sender: Any) {
        if let completion = self.completion {
            return completion(true)
        }
    }
    
    func initialize(with image: UIImage, in container: UIView, completion: @escaping (_ accepted: Bool) -> Void) {
        self.completion = completion
        self.constrain(to: container)
        self.imageView.image = image
        style()
    }
    
    func constrain(to container: UIView) {
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo:  container.centerXAnchor),
            self.centerYAnchor.constraint(equalTo:  container.centerYAnchor),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
    }
    
    // MARK: Style
    func style() {
        addShadow(to: self.layer, opacity: 0.8, height: 2)
        self.layer.cornerRadius = 5
        self.buttonsContainer.backgroundColor = Modal.buttonAccentColor
        if let retryButtonLabel = retryButton.titleLabel, let approveButtonLabel = approveButton.titleLabel {
            retryButtonLabel.font = Modal.buttonFont
            approveButtonLabel.font = Modal.buttonFont
        }
        
        self.retryButton.setTitleColor(Modal.primaryTextColor, for: .normal)
        self.approveButton.setTitleColor(Modal.primaryTextColor, for: .normal)
        self.retryButton.setTitle("Try Again", for: .normal)
        self.approveButton.setTitle("Looks Good!", for: .normal)
    }
    
    func addShadow(to layer: CALayer, opacity: Float, height: Int, radius: CGFloat? = 10) {
        layer.borderColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 10
    }
}
