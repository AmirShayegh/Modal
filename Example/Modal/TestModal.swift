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
    func initialize() {
        self.backgroundColor = UIColor.green
        setFixed(width: 200, height: 200)
        present()
    }

}
