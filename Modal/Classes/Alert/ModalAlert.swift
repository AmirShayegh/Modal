//
//  Alert.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-12-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import UIKit

public class ModalAlert {
    
    public static var titleFont = UIFont.boldSystemFont(ofSize: 18)
    public static var messageFont = UIFont.systemFont(ofSize: 16)
    public static var buttonFont = UIFont.boldSystemFont(ofSize: 16)
    
    public static var primaryColor = UIColor.black
    public static var buttonAccentColor = UIColor(hex: "#EFEFF3").withAlphaComponent(0.8)
    
    static var bundle: Bundle? {
        let podBundle = Bundle(for: ModalAlert.self)
        
        if let bundleURL = podBundle.url(forResource: "Modal", withExtension: "bundle"), let b = Bundle(url: bundleURL) {
            return b
        } else {
            print("Fatal Error: Could not find bundle for ModalAlert")
        }
        return nil
    }
    
    public static func show(title: String, message: String, yes: @escaping()-> Void, no: @escaping()-> Void) {
        guard let bundle = bundle else {return}
        let view: AlertView = ModalView.nib(bundle: bundle)
        view.initialize(mode: .YesNo, title: title, message: message, rightButtonCallback: {
            return yes()
        }) {
            return no()
        }
    }

    public static func show(title: String, message: String) {
        guard let bundle = bundle else {return}
        let view: AlertView = ModalView.nib(bundle: bundle)
        view.initialize(mode: .Message, title: title, message: message, rightButtonCallback: {}) {}
    }
    
    public static func show(title: String, message: String, rightButtonName: String, leftButtonName: String ,rightButtonAction: @escaping()-> Void, leftButtonAction: @escaping()-> Void) {
        guard let bundle = bundle else {return}
        let view: AlertView = ModalView.nib(bundle: bundle)
        view.initialize(mode: .Custom, title: title, message: message, leftButtonName: leftButtonName, rightButtonName: rightButtonName, rightButtonCallback: {
            return rightButtonAction()
        }) {
            return leftButtonAction()
        }
    }
}
