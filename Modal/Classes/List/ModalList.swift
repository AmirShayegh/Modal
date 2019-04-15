//
//  ModalList.swift
//  MyRangeBCManager
//
//  Created by Amir Shayegh on 2019-04-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

public class ModalList {
    static var bundle: Bundle? {
        let podBundle = Bundle(for: ModalList.self)
        
        if let bundleURL = podBundle.url(forResource: "Modal", withExtension: "bundle"), let b = Bundle(url: bundleURL) {
            return b
        } else {
            print("Fatal Error: Could not find bundle for ModalAlert")
        }
        return nil
    }
    
    public static func show(title: String, options: [String], cancelCallback: @escaping()-> Void, selectCallBack: @escaping(_ option: String)-> Void) {
        guard let bundle = bundle else {return}
        let view: ModalListView = ModalView.nib(bundle: bundle)
        view.initialize(title: title, options: options, cancelCallback: cancelCallback, selectCallBack: selectCallBack)
        
    }
}
