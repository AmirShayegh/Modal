//
//  TestModal.swift
//  Modal_Example
//
//  Created by Amir Shayegh on 2019-04-04.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Modal

class TestModal: ModalView {
    
    
    @IBAction func somethingAction(_ sender: UIButton) {
        remove()
    }
    
    func initialize() {
        self.backgroundColor = UIColor.green
//        setSmartSizingWith(percentHorizontalPadding: 5, percentVerticalPadding: 10)
        setFixed(width: 200, height: 200)
        present()
    }

}
