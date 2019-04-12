/*import UIKit
import AVFoundation
//import Extended
//import Designer
import CoreLocation

enum CamMode {
    case Video
    case Photo
}

public protocol CamViewControllerDelegate: class {
    func captured(image: UIImage)
}

@available(iOS 11.0, *)
public class CamViewController: UIViewController {
    
    // MARK: Constants
    let shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
    let notification = UINotificationFeedbackGenerator()
    let whiteScreenTag = 52
    let imagePreviewTag = 53
    let imageTempPreviewTag = 54
    let animationDuration: Double = 0.2
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var displayPadding: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 100
        } else {
            return 0
        }
    }
    
    // MARK: Variables
    var parentContainer: UIViewController?
    var captureSession: AVCaptureSession = AVCaptureSession()
    var photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    var videoPreviewLayer: PreviewView?
    var picPreview: UIView?
    var imageOrientation: AVCaptureVideoOrientation?
    var deviceOrientationOnCapture: UIDeviceOrientation?
    
    private var permissionGranted = false
    //    private let sessionQueue = DispatchQueue(label: "session queue")
    weak var delegate: CamViewControllerDelegate?
    private let context = CIContext()
    
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    
    var locationONSnap: CLLocation?
    var headingONSnap: CLHeading?
    
    var flashEnabled: Bool = false
    var hasFlash: Bool = false
    
    var taken: AVCapturePhoto?
    
    var primaryColor: UIColor = UIColor(hex: "#234075")
    var textColor: UIColor = UIColor.white
    
    var callBack: ((_ photo: Photo?)-> Void)?
    
    var previewing: Bool = false
    
    // MARK: Outlet
    @IBOutlet weak var cameraContainere: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup(for: .back)
        makeCircle(view: captureButton)
    }
    
    // MARK: Outlet Actions
    @IBAction func closeAction(_ sender: Any) {
        if previewing {
            guard let videoPreview = videoPreviewLayer, let imageView = self.view.viewWithTag(imagePreviewTag) as? UIImageView else {return}
            UIView.animate(withDuration: animationDuration, animations: {
                videoPreview.alpha = 1
                imageView.alpha = 0
                self.setIconsForCapture()
                self.view.layoutIfNeeded()
            }) { (done) in
                self.previewing = false
                imageView.removeFromSuperview()
            }
        } else {
            self.taken = nil
            self.close()
        }
    }
    
    @IBAction func captureAction(_ sender: Any) {
        if previewing {
            close()
        } else {
            guard let parent = self.parent, let parentView = parent.view else {return}
            // Store current location
            locationONSnap = currentLocation
            headingONSnap = currentHeading
            
            // add a screenshot while waiting to process photo
            addTempImageSnap()
            self.captureButton.isEnabled = false
            self.imageOrientation = getVideoOrientation(size: parentView.frame.size)
            let settings = setPhotoSettings()
            self.deviceOrientationOnCapture = UIDevice.current.orientation
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func addTempImageSnap() {
        return
        //        if let previewLayer = self.videoPreviewLayer {
        //            let img = previewLayer.toImage()
        //            let view = UIImageView(frame: previewLayer.frame)
        //            view.tag = imageTempPreviewTag
        //            view.contentMode = .scaleAspectFit
        //            view.image = img
        //            self.view.insertSubview(view, aboveSubview: previewLayer)
        //            addPreviewConstraints(to: view)
        //        }
    }
    
    func removeTempImageSnap() {
        guard let imageView = self.view.viewWithTag(imagePreviewTag) as? UIImageView else {return}
        imageView.removeFromSuperview()
    }
    
    func setup(for position: AVCaptureDevice.Position) {
        checkPermission()
        DispatchQueue.main.async { [unowned self] in
            self.captureSession.beginConfiguration()
            self.setInput(forDevice: position)
            self.setOutput()
            self.setPreviewView()
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
        //        sessionQueue.async { [unowned self] in
        //            self.captureSession.beginConfiguration()
        //            self.setInput(forDevice: position)
        //            self.setOutput()
        //            self.setPreviewView()
        //            self.captureSession.commitConfiguration()
        //            self.captureSession.startRunning()
        //        }
    }
    
    func configureSession() {
        guard permissionGranted else { return }
        //        self.captureSession.beginConfiguration()
        //        self.setInput(forDevice: position)
        //        let videoOutput = AVCaptureVideoDataOutput()
        //        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
    }
    
    // MARK: AVSession configuration
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
        //        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            //            self.sessionQueue.resume()
        }
    }
    
    func setPreviewView() {
        self.view.layoutIfNeeded()
        guard let parent = self.parent, let parentView = parent.view else {return}
        let preview: PreviewView = UIView.fromNib(bundle: ModalCamera.bundle)
        preview.videoPreviewLayer.session = self.captureSession
        preview.position(in: cameraContainere, behind: captureButton)
        self.videoPreviewLayer = preview
        setVideoOrientation(for: parentView.frame.size)
        self.view.addSubview(captureButton)
        self.view.addSubview(closeButton)
        styleContainer(layer: preview)
        preview.clipsToBounds = true
        addPreviewConstraints(to: preview)
    }
    
    
    func setInput(forDevice position: AVCaptureDevice.Position) {
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: getCamera(for: position)),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
    }
    
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
    
    func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                for: .video, position: position) {
            self.hasFlash = device.hasFlash
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: position) {
            self.hasFlash = device.hasFlash
            return device
        } else {
            fatalError("Missing expected back camera device.")
        }
    }
    
    // MARK: Screen rotation
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.view.layoutIfNeeded()
        setVideoOrientation(for: size)
        place(with: size)
    }
    
    func setVideoOrientation(for size: CGSize) {
        if let preview = self.videoPreviewLayer, let connection = preview.videoPreviewLayer.connection {
            connection.videoOrientation = getVideoOrientation(size: size)
        }
    }
    
    func getVideoOrientation(size: CGSize) -> AVCaptureVideoOrientation {
        self.view.layoutIfNeeded()
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
    
    // MARK: White Screen
    func whiteScreen() -> UIView? {
        guard let p = parent else {return nil}
        let view = UIView(frame: CGRect(x: 0, y: 0, width: p.view.frame.width, height: p.view.frame.height))
        view.center.y = p.view.center.y
        view.center.x = p.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.5)
        view.alpha = 1
        view.tag = whiteScreenTag
        
        return view
    }
    
    func setWhiteScreen() {
        guard let p = parent, let screen = whiteScreen() else {return}
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cancelled(_:)))
        screen.alpha = 0
        p.view.insertSubview(screen, belowSubview: self.view)
        screen.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            screen.trailingAnchor.constraint(equalTo: p.view.trailingAnchor),
            screen.leadingAnchor.constraint(equalTo: p.view.leadingAnchor),
            screen.topAnchor.constraint(equalTo: p.view.topAnchor),
            screen.bottomAnchor.constraint(equalTo: p.view.bottomAnchor)
            ])
        screen.addGestureRecognizer(tap)
        UIView.animate(withDuration: animationDuration, animations: {
            screen.alpha = 1
        })
    }
    
    func removeWhiteScreen() {
        guard let p = parent else {return}
        if let viewWithTag = p.view.viewWithTag(whiteScreenTag) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    
    public func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }
    
    @objc func cancelled(_ sender: UISwipeGestureRecognizer) {
        self.taken = nil
        close()
    }
    
    
    // MARK: Display and remove
    func display(on parent: UIViewController, buttonAndBackgroundColor: UIColor? = .white, buttonTextColor: UIColor? = .black, then: @escaping (_ photo: Photo?)-> Void) {
        self.parentContainer = parent
        self.callBack = then
        
        if let primary = buttonAndBackgroundColor {
            self.primaryColor = primary
        }
        if let textClr = buttonTextColor {
            self.textColor = textClr
        }
        
        style()
        
        parent.addChild(self)
        positionPreAnimation(in: parent)
        parent.view.addSubview(self.view)
        self.didMove(toParent: parent)
        setWhiteScreen()
        UIView.animate(withDuration: animationDuration, animations: {
            self.position(in: parent)
        })
        initLocation()
    }
    
    func close() {
        guard let p = parent else {return}
        self.captureSession.stopRunning()
        UIView.animate(withDuration: animationDuration, animations: {
            self.positionPreAnimation(in: p)
            if let whiteScreen = p.view.viewWithTag(self.whiteScreenTag) {
                whiteScreen.alpha = 0
            }
        }) { (done) in
            self.remove()
        }
    }
    
    func remove() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingLocation()
        notification.notificationOccurred(.error)
        if let pic = self.picPreview {
            pic.removeFromSuperview()
        }
        self.removeWhiteScreen()
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.didMove(toParent: nil)
        self.dismiss(animated: true, completion: nil)
        if let callback = self.callBack {
            return callback(convert(photo: taken))
        }
    }
    
    // MARK: Placement
    func positionPreAnimation(in parentVC: UIViewController ) {
        let parentHeight = parentVC.view.frame.size.height
        let suggested = getFrame(for: parentVC.view.frame.size)
        
        view.frame = CGRect(x: 0, y: parentHeight, width: suggested.width, height: suggested.height)
        view.center.x = parentVC.view.center.x
        view.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor)
        self.view.layoutIfNeeded()
    }
    
    func position(in parentVC: UIViewController ) {
        let parentHeight = parentVC.view.frame.size.height
        let suggested = getFrame(for: parentVC.view.frame.size)
        
        view.frame = CGRect(x: 0, y: parentHeight - suggested.height , width: suggested.width, height: suggested.height)
        view.center.x = parentVC.view.center.x
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let heightAnchor: NSLayoutConstraint = view.heightAnchor.constraint(equalToConstant: suggested.height)
        var topAnchor: NSLayoutConstraint?
        
        if let superview = parentVC.view.superview, UIDevice.current.userInterfaceIdiom == .pad {
            topAnchor = view.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: superview.topAnchor, multiplier: 0)
        } else {
            topAnchor = view.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: parentVC.view.topAnchor, multiplier: 5)
        }
        heightAnchor.priority = .init(750)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor),
            view.widthAnchor.constraint(equalToConstant: suggested.width),
            heightAnchor,
            view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor),
            topAnchor!
            ])
        
        self.view.layoutIfNeeded()
    }
    
    func place(with size: CGSize) {
        let suggested = getFrame(for: size)
        self.view.frame = CGRect(x: 0, y: size.height - suggested.height , width: suggested.width, height: suggested.height)
        self.view.layoutIfNeeded()
    }
    
    func getFrame(for size: CGSize) -> CGRect {
        self.view.layoutIfNeeded()
        if size.width > size.height {
            //landscape
            let basicHeight = size.height - displayPadding
            let width = (basicHeight * 4) / 3
            return CGRect(x: 0, y: 0, width: width, height: basicHeight)
        } else {
            //portrait
            let width =  size.width - displayPadding
            let height = (width * 4) / 3
            return CGRect(x: 0, y: 0, width: width, height: height)
        }
    }
    
    func addPreviewConstraints(to: UIView) {
        to.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            to.leadingAnchor.constraint(equalTo: self.cameraContainere.leadingAnchor),
            to.trailingAnchor.constraint(equalTo: self.cameraContainere.trailingAnchor),
            to.bottomAnchor.constraint(equalTo: self.cameraContainere.bottomAnchor)
            ])
    }
    
    func addImagePreviewConstraints(to: UIView) {
        to.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            to.leadingAnchor.constraint(equalTo: self.cameraContainere.leadingAnchor),
            to.trailingAnchor.constraint(equalTo: self.cameraContainere.trailingAnchor),
            to.bottomAnchor.constraint(equalTo: self.cameraContainere.bottomAnchor),
            to.topAnchor.constraint(equalTo: self.cameraContainere.topAnchor)
            ])
    }
    
    // MARK: Style
    func style() {
        if self.captureButton == nil {return}
        self.cameraContainere.backgroundColor = .black
        cameraContainere.clipsToBounds = true
        self.view.clipsToBounds = true
        styleContainer(layer: cameraContainere)
        style(button: captureButton, bg: primaryColor, tint: textColor)
        style(button: closeButton,bg: primaryColor, tint: textColor)
        styleContainer(layer: self.view)
        setIconsForCapture()
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
    
    func showPreview(of avCapturePhoto: AVCapturePhoto) {
        guard let photo = convert(photo: avCapturePhoto), let image = photo.image, let videoPreview = videoPreviewLayer else {return}
        let imageView = UIImageView(frame: self.cameraContainere.frame)
        imageView.tag = imagePreviewTag
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        previewing = true
        self.view.insertSubview(imageView, aboveSubview: videoPreview)
        addImagePreviewConstraints(to: imageView)
        UIView.animate(withDuration: animationDuration, animations: {
            videoPreview.alpha = 0
            self.setIconsForPreview()
            self.view.layoutIfNeeded()
        }) { (done) in
            self.view.addSubview(self.captureButton)
            self.view.addSubview(self.closeButton)
        }
    }
    
    func setIconsForCapture() {
        if let cancel = UIImage(named: "cancel", in: ModalCamera.bundle, compatibleWith: nil) {
            self.closeButton.setTitle("", for: .normal)
            self.closeButton.setImage(cancel, for: .normal)
            if let buttonImage = closeButton.imageView {
                buttonImage.contentMode = .scaleAspectFit
                closeButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            }
            
            makeCircle(view: closeButton)
        } else {
            self.closeButton.setTitle("Close", for: .normal)
        }
        self.captureButton.setTitle("Capture", for: .normal)
        closeButton.alpha = 0.8
        captureButton.alpha = 0.8
    }
    
    func setIconsForPreview() {
        if let garbage = UIImage(named: "garbage", in: ModalCamera.bundle, compatibleWith: nil) {
            self.closeButton.setTitle("", for: .normal)
            self.closeButton.setImage(garbage, for: .normal)
            if let buttonImage = closeButton.imageView {
                buttonImage.contentMode = .scaleAspectFit
                closeButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            }
            makeCircle(view: closeButton)
        } else {
            self.closeButton.setTitle("Back", for: .normal)
        }
        self.captureButton.setTitle("Accept", for: .normal)
        closeButton.alpha = 0.8
        captureButton.alpha = 0.8
    }
    
}

// MARK: Handle image return
extension CamViewController: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("taken")
        self.taken = photo
        showPreview(of: photo)
        self.captureButton.isEnabled = true
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //        print("Caught a frame")
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
    
    //    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    //        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
    //        DispatchQueue.main.async { [unowned self] in
    //            if self.delegate != nil {
    //                self.delegate?.captured(image: uiImage)
    //            }
    //        }
    //    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    
    func styleContainer(layer: UIView) {
        roundTopCorners(view: layer, by: 15)
//        addShadow(to: layer.layer, opacity: 0.4, height: 2)
    }
    
    func roundTopCorners(view: UIView, by: CGFloat) {
        view.clipsToBounds = true
        view.layer.cornerRadius = by
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func style(button: UIButton, bg: UIColor, tint: UIColor) {
        makeCircle(view: button)
        button.backgroundColor = bg
        button.tintColor = tint
        button.setTitleColor(tint, for: .normal)
    }
}

// MARK: Location
extension CamViewController: CLLocationManagerDelegate {
    func initLocation() {
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 1
            
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    // If we have been deined access give the user the option to change it
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "In order to show the polling stations around you, we need access to your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alertController.addAction(openAction)
        if let parent = self.parentContainer {
            parent.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.currentHeading = newHeading
    }
}
*/

