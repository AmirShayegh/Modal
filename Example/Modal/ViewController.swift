//
//  ViewController.swift
//  Modal
//
//  Created by amirshayegh on 04/03/2019.
//  Copyright (c) 2019 amirshayegh. All rights reserved.
//

import UIKit
import Modal

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let test: TestModal = TestModal.nib()
        test.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

