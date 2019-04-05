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
    @IBAction func show(_ sender: Any) {
        // Alert
//        ModalAlert.show(title: "hello", message: "world")
        // Custom modal
//        let test: TestModal = TestModal.nib()
//        test.initialize()
        // List
        ModalList.show(title: "hello", options: ["One","Two","Three","Four","Five"], cancelCallback: {
            ModalAlert.show(title: "You.....", message: "Cancelled")
        }) { (selected) in
            ModalAlert.show(title: "You selected", message: selected)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

