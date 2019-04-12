//
//  Cam.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-21.
//

import Foundation
import AVFoundation
import UIKit

@available(iOS 11.0, *)

public class ModalCamera {

    public init() {}

    public static weak var delegate: CameraViewDelegate?

    static var bundle: Bundle? {
        let podBundle = Bundle(for: CameraView.self)
        
        if let bundleURL = podBundle.url(forResource: "Modal", withExtension: "bundle"), let b = Bundle(url: bundleURL) {
            return b
        } else {
            print("Fatal Error: Could not find bundle for ModalAlert")
        }
        return nil
    }
    
    public static func show(result: @escaping(_ photo: Photo?) -> Void?) {
        guard let bundle = bundle else {return}
        let view: CameraView = ModalView.nib(bundle: bundle)
        view.initialize(result: result)
    }

    // Picker view controller
//    public lazy var camVC: CameraViewDelegate = {
//        return UIStoryboard(name: "Cam", bundle: ModalCamera.bundle).instantiateViewController(withIdentifier: "Cam") as! CamViewController
//    }()

//    public static func display(on parent: UIViewController, then: @escaping (_ photo: Photo?)-> Void) {
//        guard let bundle = bundle else {return}
//        let cameraView: CameraView = ModalView.nib(bundle: bundle)
////        let cameraView: CameraView = CameraView.nib()
//        cameraView.delegate = delegate
//        cameraView.display(on: parent, buttonAndBackgroundColor: UIColor(hex: "#234075"), buttonTextColor: .white, then: then)
//
//    }
}

