//
//  Modal.swift
//  Modal
//
//  Created by Amir Shayegh on 2019-04-05.
//

import Foundation

public struct ModalStyle {
    public var shared = Shared()
    public var alert = Alert()
    public var list = List()
    public var camera = Camera()
    
    public struct Shared {
        public var titleFont = UIFont.boldSystemFont(ofSize: 18)
        
        public var textColor: UIColor = UIColor.black
        public var screenColor: UIColor = UIColor.white.withAlphaComponent(0.8)
        public var dividerColor = UIColor(hex: "#EFEFF3").withAlphaComponent(0.8)
        public var closeButtonColor = UIColor.black.withAlphaComponent(0.9)
        
        public var dividerHeight: CGFloat = 1
        public var titleBarHeight: CGFloat = 42
    }
    
    public struct Alert {
        
        public var titleFont = UIFont.boldSystemFont(ofSize: 18)
        public var messageFont = UIFont.systemFont(ofSize: 16)
        public var buttonFont = UIFont.boldSystemFont(ofSize: 16)
        public var buttonTitleColor = UIColor.black
        public var buttonAccentColor = UIColor(hex: "#EFEFF3").withAlphaComponent(0.8)
    }
    
    public struct List {
        public var optionColor = UIColor.black
        public var optionFont = UIFont.systemFont(ofSize: 16)
    }
    
    public struct Camera {
        public var buttonColor = UIColor.black
    }
}


public class Modal {
    public static var style = ModalStyle()
    
    public static let alert = ModalAlert()

    // MARK: Bundle
    static var bundle: Bundle? {
        let podBundle = Bundle(for: Modal.self)
        
        if let bundleURL = podBundle.url(forResource: "Modal", withExtension: "bundle"), let b = Bundle(url: bundleURL) {
            return b
        } else {
            print("Fatal Error: Could not find bundle for ModalAlert")
        }
        return nil
    }
}
