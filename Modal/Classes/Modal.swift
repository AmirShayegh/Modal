//
//  Modal.swift
//  Modal
//
//  Created by Amir Shayegh on 2019-04-05.
//

import Foundation


public class Modal {
    public static var dividerHeight: CGFloat = 1
    public static var titleBarHeight: CGFloat = 42
    
    // MARK: Colours
    public static var screenColor: UIColor = UIColor.white.withAlphaComponent(0.8)
    
    public static var dividerColor = UIColor(hex: "#EFEFF3").withAlphaComponent(0.8)
    public static var titleColor = Modal.primaryTextColor
    public static var optionColor = Modal.primaryTextColor
    public static var closeButtonColor = Modal.primaryTextColor.withAlphaComponent(0.9)
    public static var buttonAccentColor = Modal.dividerColor
    
    // TODO: better handling of colour set up,
    public static var primaryTextColor = UIColor.black
    public static var secondaryColor = UIColor.black
    
    // MARK: Fonts
    public static var titleFont = UIFont.boldSystemFont(ofSize: 18)
    public static var buttonFont = UIFont.boldSystemFont(ofSize: 16)
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
