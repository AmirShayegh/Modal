//
//  CameraView.swift
//  Modal
//
//  Created by Amir Shayegh on 2019-04-11.
//

import Foundation
import UIKit
import AVFoundation
import CoreLocation
import Lottie

enum CameraMode {
    case Video
    case Photo
}

// TODo: Rename
public protocol CameraViewDelegate: class {
    func captured(image: UIImage)
}

// TODo: Rename
class CameraView: ModalView {
    // MARK: Constants
    private let notification = UINotificationFeedbackGenerator()
    private let context = CIContext()
    private let lottieCaptureIconTag = Int.random(in: 1000..<1000000)
    private let lottieCaptureIconName = "circle"
    private let imagePreviewTag = Int.random(in: 1000..<1000000)
    // MARK: Variables
    private var currentWindowWidth: CGFloat = 0
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var permissionGranted = false
    
    private var resultCallBack: ((_ photo: Photo)-> Void)?
    private var cancelCallBack: (()-> Void)?
    private var imageOrientation: AVCaptureVideoOrientation?
    private var deviceOrientationOnCapture: UIDeviceOrientation?
    private weak var delegate: CameraViewDelegate?
    private var videoPreviewLayer: PreviewView?
    private var picPreview: UIView?
    private var currentLocation: CLLocation?
    private var currentHeading: CLHeading?
    private var locationONSnap: CLLocation?
    private var headingONSnap: CLHeading?
    
    private var isCapturing = false
    private var previewing = false
    
    var flashEnabled: Bool = false
    var hasFlash: Bool = false
    var cameraPosition: AVCaptureDevice.Position = .back
    var cameraMode: CameraMode = .Photo
    
    var displayPadding: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 100
        } else {
            return 0
        }
    }
    
    weak var taken: AVCapturePhoto?
    
    // MARK: Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var dividerHeight: NSLayoutConstraint!
    @IBOutlet weak var dividerBottomPadding: NSLayoutConstraint!
    
    @IBOutlet weak var titleBarHeight: NSLayoutConstraint!
    @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var captureButtonContainer: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cameraPositionButton: UIButton!
    @IBOutlet weak var cameraModeButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var cameraButtonsStack: UIStackView!
    
    @IBAction func changeCameraMode(_ sender: Any) {
        
    }
    
    @IBAction func switchCameraPosition(_ sender: Any) {
        captureSession.stopRunning()
        switch cameraPosition {
        case .unspecified:
            setup(for: .back)
        case .back:
            setup(for: .front)
        case .front:
            setup(for: .back)
        }
        setFlashIcon()
    }
    
    @IBAction func switchFlash(_ sender: Any) {
        self.flashEnabled = !self.flashEnabled
        self.setFlashIcon()
    }
    
    @objc func captureAction(_ sender:UITapGestureRecognizer) {
        if isCapturing {return}
        notification.notificationOccurred(.success)
        playCaptureAnimation()
        captureImage()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        sendCallback(photo: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let window = UIApplication.shared.keyWindow else {return}
        if window.frame.width != currentWindowWidth {
            self.currentWindowWidth = window.frame.width
            changeSizeToSuggestedSize()
        }
    }
    
    func changeSizeToSuggestedSize() {
        if !previewing {
            captureSession.stopRunning()
        }
        
        guard let window = UIApplication.shared.keyWindow else {return}
        let suggestedSize = getFrame(for: window.frame.size)
        changeSizeTo(width: suggestedSize.width, height: suggestedSize.height)
        if !previewing {
            setup(for: cameraPosition)
        }
    }
    
    // MARK: Result
    func sendCallback(photo: Photo?) {
        notification.notificationOccurred(.success)
        teardown()
        remove()
        if let result = photo, let callback = self.resultCallBack {
            return callback(result)
        } else if let callback = self.cancelCallBack {
            return callback()
        }
    }
    
    // MARK: Entry Point
    func initialize(initialPosition: AVCaptureDevice.Position = .back, result: @escaping(_ photo: Photo) -> Void, cancelled: @escaping () -> Void) {
        guard let window = UIApplication.shared.keyWindow else {return}
        self.currentWindowWidth = window.frame.width
        let suggestedSize = getFrame(for: window.frame.size)
        setFixed(width: suggestedSize.width, height: suggestedSize.height)
        present()
        style()
        setup(for: initialPosition)
        initializeCaptureButton()
        self.resultCallBack = result
        self.cancelCallBack = cancelled
//        initLocation()
    }
    
    func initializeCaptureButton() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(captureAction(_:)))
        captureButtonContainer.addGestureRecognizer(gesture)
    }
    
    // MARK: Sizing
    func getFrame(for size: CGSize) -> CGRect {
        self.layoutIfNeeded()
        let addedTopBarHeight = Modal.style.shared.dividerHeight + Modal.style.shared.titleBarHeight
        if size.width > size.height {
            var availableHeight = size.height - displayPadding
            availableHeight -= (Modal.style.shared.dividerHeight + Modal.style.shared.titleBarHeight)
            if previewing {
                availableHeight -= AlertImageDialog.buttonBarHeight
            }
            let esitamtedWidth = (availableHeight * 4) / 3
            
            return CGRect(x: 0, y: 0, width: esitamtedWidth, height: size.height - displayPadding)
        } else {
            //portrait
            let width =  size.width - displayPadding
            let height = (width * 4) / 3
            var suggestedHeight = height
            suggestedHeight += addedTopBarHeight
            if previewing {
                suggestedHeight += AlertImageDialog.buttonBarHeight
            }
            if suggestedHeight > size.height {
                suggestedHeight = size.height
            }
            return CGRect(x: 0, y: 0, width: width, height: suggestedHeight)
        }
    }
    
    // MARK: Camera Setup
    func setup(for position: AVCaptureDevice.Position) {
        self.cameraButtonsStack.alpha = 1
        self.previewView.alpha = 1
        checkPermission()
        DispatchQueue.main.async { [unowned self] in
            self.captureSession.beginConfiguration()
            self.setInput(forDevice: position)
            self.setOutput()
            self.setPreviewView()
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func teardown() {
        locationManager.stopUpdatingLocation()
        notification.notificationOccurred(.error)
        captureSession.stopRunning()
        if let preview = self.picPreview {
            preview.removeFromSuperview()
        }
    }
    // MARK: AVSession configuration
    /******************** INPUT CAMERA SETUP ********************/
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setInput(forDevice position: AVCaptureDevice.Position) {
        self.cameraPosition = position
        if let currentInput = self.videoDeviceInput {
            captureSession.removeInput(currentInput)
        }
        guard let device = getCamera(for: position) else {
            ModalAlert.show(title: "Error", message: "Missing Camera.")
            return
        }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device) else {
            ModalAlert.show(title: "Error", message: "Couldn't set input device.")
            return
        }
        guard captureSession.canAddInput(videoDeviceInput) else {
            ModalAlert.show(title: "Error", message: "Couldn't initialize Camera.")
            return
        }
        captureSession.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
    }
    
    func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
            self.hasFlash = device.hasFlash
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            self.hasFlash = device.hasFlash
            return device
        } else {
            return nil
        }
    }
    /******************** END INPUT CAMERA SETUP ********************/
    /******************** Output SETUP ********************/
    // Note: Currently only supports photo.
    /*
     In order to support video or video and photo,
     add both AVCapturePhotoOutput and AVCaptureMovieFileOutput to session.
     https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/setting_up_a_capture_session
     Also note the for video, we would have to change input to record from the microphone too.
     */
    func setOutput() {
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoCaptureEnabled = false
        guard self.captureSession.canAddOutput(photoOutput) else { return }
        self.captureSession.sessionPreset = .photo
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard self.captureSession.canAddOutput(videoOutput) else {return}
        self.captureSession.addOutput(videoOutput)
        self.captureSession.addOutput(photoOutput)
        self.captureSession.commitConfiguration()
    }
    
    /* Called by Setup() */
    func setPreviewView() {
        if let previewLayer = self.videoPreviewLayer {
            previewLayer.removeFromSuperview()
        }
         self.layoutIfNeeded()
        let preview: PreviewView = UIView.fromNib(bundle: ModalCamera.bundle)
        preview.videoPreviewLayer.session = self.captureSession
        preview.position(in: previewView, behind: captureButtonContainer)
        self.videoPreviewLayer = preview
        setVideoOrientation(for: self.frame.size)
        preview.clipsToBounds = true
        addPreviewConstraints(to: preview)
    }
    
    /* Called by setPreviewView() */
    func addPreviewConstraints(to: UIView) {
        to.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            to.leadingAnchor.constraint(equalTo: self.previewView.leadingAnchor),
            to.trailingAnchor.constraint(equalTo: self.previewView.trailingAnchor),
            to.bottomAnchor.constraint(equalTo: self.previewView.bottomAnchor)
            ])
    }
    
    /* Called by setPreviewView()*/
    func setVideoOrientation(for size: CGSize) {
        if let preview = self.videoPreviewLayer, let connection = preview.videoPreviewLayer.connection {
            connection.videoOrientation = getVideoOrientation(size: size)
        }
    }
    
    /* Called by setVideoOrientation(for size: CGSize) */
    func getVideoOrientation(size: CGSize) -> AVCaptureVideoOrientation {
        self.layoutIfNeeded()
        if size.width > size.height {
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                return .landscapeRight
            } else {
                return .landscapeLeft
            }
        } else {
            //portrait
            if UIDevice.current.orientation == UIDeviceOrientation.portrait {
                return .portrait
            } else if UIDevice.current.orientation == UIDeviceOrientation.faceUp || UIDevice.current.orientation == UIDeviceOrientation.faceDown {
                return .portrait
            } else {
                return .portraitUpsideDown
            }
        }
    }
    /******************** END Output ********************/
    /******************** Capture  ********************/
    func captureImage() {
        locationONSnap = currentLocation
        headingONSnap = currentHeading
        
        // add a screenshot while waiting to process photo
        //        addTempImageSnap()
        self.isCapturing = true
        self.imageOrientation = getVideoOrientation(size: self.frame.size)
        let settings = setPhotoSettings()
        self.deviceOrientationOnCapture = UIDevice.current.orientation
        self.photoOutput.capturePhoto(with: settings, delegate: self)

    }
    
    func setPhotoSettings() -> AVCapturePhotoSettings {
        var photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
        if self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
            photoSettings = AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        if flashEnabled, hasFlash {
            photoSettings.flashMode = .on
        } else {
            photoSettings.flashMode = .off
        }
        photoSettings.isAutoStillImageStabilizationEnabled =
            self.photoOutput.isStillImageStabilizationSupported
        return photoSettings
    }
    /******************** END Capture  ********************/
    
    // MARK: Style
    func style() {
        addShadow(to: self.layer, opacity: 0.8, height: 2)
        self.layer.cornerRadius = 5
        self.cancelButton.setTitle("", for: .normal)
        setIcons()
        divider.backgroundColor = Modal.style.shared.dividerColor
        self.titleBarHeight.constant = Modal.style.shared.titleBarHeight
        self.closeButtonHeight.constant = calc(percent: 70, of:  Modal.style.shared.titleBarHeight)
        self.dividerHeight.constant = Modal.style.shared.dividerHeight
        addButtomShadow(to: divider, color: Modal.style.shared.dividerColor.cgColor, opacity: 0.9)
        addLottieCaptureIcon()
    }
    
    func addLottieCaptureIcon() {
        let animationView = AnimationView()
        guard let bundle = Modal.bundle, let animation: Animation = Animation.named(lottieCaptureIconName, bundle: bundle) else {
            return
        }
        animationView.animation = animation
        animationView.tag = self.lottieCaptureIconTag
        
        // Position Icon
        animationView.frame = self.captureButtonContainer.frame
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        captureButtonContainer.addSubview(animationView)
        // Add constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: captureButtonContainer.frame.width),
            animationView.heightAnchor.constraint(equalToConstant: captureButtonContainer.frame.height),
            animationView.centerXAnchor.constraint(equalTo: captureButtonContainer.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: captureButtonContainer.centerYAnchor),
            ])
        self.layoutIfNeeded()
        self.captureButtonContainer.layoutIfNeeded()
    }
    
    func playCaptureAnimation() {
        if let icon = captureButtonContainer.viewWithTag(lottieCaptureIconTag) as? AnimationView  {
            icon.loopMode = .loop
            icon.play()
        }
    }
    
    func stopCaptureAnimation() {
        if let icon = captureButtonContainer.viewWithTag(lottieCaptureIconTag) as? AnimationView  {
            icon.loopMode = .playOnce
        }
    }
    
    func setIcons() {
        setIcon(for: cancelButton, iconName: "close", tint: Modal.style.shared.closeButtonColor, alt: "Close")
        setIcon(for: cameraPositionButton, iconName: "camera-flip", tint: Modal.style.camera.buttonColor, alt: "Flip")
        setFlashIcon()
        setCameraModeIcon()
    }
    
    func setFlashIcon() {
        var iconName = "flash-off"
        if flashEnabled {
            iconName = "flash"
        }
        setIcon(for: flashButton, iconName: iconName, tint: Modal.style.camera.buttonColor, alt: iconName)
    }
    
    func setCameraModeIcon() {
        var iconName = "photo"
        switch cameraMode {
        case .Video:
             iconName = "video" 
        case .Photo:
             iconName = "photo"
        }
        setIcon(for: cameraModeButton, iconName: iconName, tint: Modal.style.camera.buttonColor, alt: iconName)
    }
    
    func setIcon(for button: UIButton, iconName: String, tint: UIColor, alt: String) {
        if let icon = UIImage(named: iconName, in: Modal.bundle, compatibleWith: nil) {
            button.setImage(icon, for: .normal)
            if let buttonImage = button.imageView {
                buttonImage.contentMode = .scaleAspectFit
                button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            }
            button.tintColor = tint
        } else {
            button.setTitle(alt, for: .normal)
        }
    }
    
}
// MARK: Handle image return
extension CameraView: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        self.taken = photo
        showPreview(of: photo)
        self.isCapturing = false
        self.stopCaptureAnimation()
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            if let delegate = self.delegate {
                delegate.captured(image: uiImage)
            }
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func convert(photo: AVCapturePhoto?) -> Photo? {
        guard let photo = photo, let cgImageRepresentation = photo.cgImageRepresentation(), let orientationOnCapture = deviceOrientationOnCapture else {
            return nil
        }
        
        let cgImage = cgImageRepresentation.takeUnretainedValue()
        
        guard let copy = cgImage.copy() else {
            return nil
        }
        
        let img = UIImage(cgImage: copy, scale: 1.0, orientation: orientationOnCapture.getUIImageOrientationFromDevice())
        
        let processed = Photo(image: img, timeStamp: photo.timestamp, location: locationONSnap, heading: headingONSnap, metadata: photo.metadata)
        
        return processed
    }
    
    func increaseViewHeightForAlertImageDialog() {
        guard let heightConstraint = self.contraintsAdded[.Height] else {return}
        UIView.animate(withDuration: 0.3, animations: {
            heightConstraint.constant = heightConstraint.constant + AlertImageDialog.buttonBarHeight
            self.previewView.alpha = 1
            self.cameraButtonsStack.alpha = 0
            self.layoutIfNeeded()
        }) { (done) in
            self.changeSizeToSuggestedSize()
        }
    }
    
    func decreaseViewHeightAfterAlerImageDialog() {
        guard let heightConstraint = self.contraintsAdded[.Height] else {return}
        UIView.animate(withDuration: 0.3, animations: {
            heightConstraint.constant = heightConstraint.constant - AlertImageDialog.buttonBarHeight
            self.previewView.alpha = 1
            self.cameraButtonsStack.alpha = 1
            self.layoutIfNeeded()
        }) { (done) in
            self.changeSizeToSuggestedSize()
        }
    }
    
    func showPreview(of avCapturePhoto: AVCapturePhoto) {
        guard let photo: Photo = convert(photo: avCapturePhoto), let image: UIImage = photo.image else {
            print("Couldnt not get photo from AVCapturePhoto")
            return
        }
        prepareforPreview()
        ModalCamera.showPreviewDialog(with: image, in: previewView, approved: {
            self.sendCallback(photo: photo)
            return
        }) {
            self.previewing = false
            self.taken = nil
            self.notification.notificationOccurred(.warning)
            self.decreaseViewHeightAfterAlerImageDialog()
            return
        }
    }
    
    func prepareforPreview() {
        guard let videoPreview = videoPreviewLayer else {return}
        self.previewing = true
        self.captureSession.stopRunning()
        videoPreview.removeFromSuperview()
        increaseViewHeightForAlertImageDialog()
    }
}

