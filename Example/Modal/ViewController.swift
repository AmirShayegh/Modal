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
    
    @IBAction func list(_ sender: Any) {
        ModalList.show(title: "hello", options: ["One","Two","Three","Four","Five"], cancelCallback: {
            ModalAlert.show(title: ":(", message: "You Cancelled")
        }) { (selected) in
            ModalAlert.show(title: "Selected", message: selected)
        }
    }
    
    @IBAction func camera(_ sender: Any) {
        ModalCamera.show(result: { (result) -> Void? in
            print(result)
        })
    }
    
    @IBAction func alert(_ sender: Any) {
        func thanksForInput(liked: Bool) {
            var message = "Glad you like it"
            if !liked {
                message = "its just your opinion"
            }
            ModalAlert.show(title: "I see..", message: message)
        }
        ModalAlert.show(title: "Hello World", message: "How do you feel about this?", rightButtonName: "Awesome!", leftButtonName: "Sucks", rightButtonAction: {
            ModalAlert.show(title: "Sweet", message: "Do you think this is useful?", yes: {
                thanksForInput(liked: true)
            }, no: {
                thanksForInput(liked: false)
            })
        }) {
            ModalAlert.show(title: "sorry to hear that", message: "Do you think this is useful?", yes: {
                thanksForInput(liked: true)
            }, no: {
                thanksForInput(liked: false)
            })
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

