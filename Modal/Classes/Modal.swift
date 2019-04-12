//
//  Modal.swift
//  Modal
//
//  Created by Amir Shayegh on 2019-04-05.
//

import Foundation


public class Modal {
    public static var titleBarHeight: CGFloat = 42
    
    // MARK: Colours
    public static var screenColor: UIColor = UIColor.white.withAlphaComponent(0.8)
    
    public static var dividerColor = UIColor(hex: "#EFEFF3").withAlphaComponent(0.8)
    public static var titleColor = UIColor.black
    public static var optionColor = UIColor.black
    public static var closeButtonColor = UIColor.lightGray
    
    // TODO: better handling of colour set up,
    public static var secondaryColor = UIColor.lightGray
    
    // MARK: Fonts
    public static var titleFont = UIFont.boldSystemFont(ofSize: 18)
    
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
