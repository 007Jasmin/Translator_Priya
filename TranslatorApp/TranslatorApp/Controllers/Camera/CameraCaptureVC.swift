//
//  ViewController.swift
//  Camera
//
//  Created by Rizwan on 16/06/17.
//  Copyright © 2017 Rizwan. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CameraCaptureVC: UIViewController {
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var captureButton: UIButton!
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image:UIImage?
    private var textDetectionRequest: VNDetectTextRectanglesRequest?
    private let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isAuthorized() {
            configureTextDetection()
            setupCaptureSession()
        }
        self.captureButton.layer.cornerRadius = self.captureButton.frame.height / 2
        
//        setupDevice()
//        setupInputOutput()
//        setupPreviewLayer()
//        startRunningCaptureSession(
    }
    private func configureTextDetection() {
        textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: handleDetection)
        textDetectionRequest!.reportCharacterBoxes = true
    }
    
    func setupCaptureSession() {
        previewView.session = session
        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        var cameraDevice: AVCaptureDevice?
        for device in cameraDevices.devices {
            if device.position == .back {
                cameraDevice = device
                break
            }
        }
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            session.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            session.addOutput(photoOutput!)
        }
        catch {
            print("Error occured \(error)")
            return
        }
        session.sessionPreset = .high
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        previewView.videoPreviewLayer.videoGravity = .resize
        DispatchQueue.main.async {
            self.session.startRunning()
        }
    }
    
    @IBAction func btnDismiss(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    /*func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }*/
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func handleDetection(request: VNRequest, error: Error?) {
        guard let detectionResults = request.results else {
            print("No detection results")
            return
        }
        let textResults = detectionResults.map() {
            return $0 as? VNTextObservation
        }
        if textResults.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.previewView.layer.sublayers?.removeSubrange(1...)
            let viewWidth = self.previewView.frame.size.width
            let viewHeight = self.previewView.frame.size.height
            for result in textResults {

                if let textResult = result {
                    
                    let layer = CALayer()
                    var rect = textResult.boundingBox
                    rect.origin.x *= viewWidth
                    rect.size.height *= viewHeight
                    rect.origin.y = ((1 - rect.origin.y) * viewHeight) - rect.size.height
                    rect.size.width *= viewWidth

                    layer.frame = rect
                    layer.borderWidth = 2
                    layer.borderColor = UIColor.red.cgColor
                    self.previewView.layer.addSublayer(layer)
                }
            }
        }
    }
//    private var preview: PreviewView {
//        return view as! PreviewView
//    }
    private func isAuthorized() -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                          completionHandler: { (granted:Bool) -> Void in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.configureTextDetection()
                    }
                }
            })
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        }
    }
  
}

extension CameraCaptureVC {
    
    @IBAction func onTapTakePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func btnSelectPhoto(_ sender:UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //imagePicker.mediaTypes = [kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
}
//MARK: - UINavigationControllerDelegate
extension CameraCaptureVC: UINavigationControllerDelegate { }
//MARK: - UIImagePickerControllerDelegate
extension CameraCaptureVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        dismiss(animated: true) {
            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: CaptureImageVC.className) as! CaptureImageVC
            vc.img1 = selectedPhoto
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - AVCapturePhotoCaptureDelegate
extension CameraCaptureVC : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)
            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: CaptureImageVC.className) as! CaptureImageVC
            vc.img1 = image ?? UIImage()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension CameraCaptureVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Camera Delegate and Setup
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var imageRequestOptions = [VNImageOption: Any]()
        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            imageRequestOptions[.cameraIntrinsics] = cameraData
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
        do {
            try imageRequestHandler.perform([textDetectionRequest!])
        }
        catch {
            print("Error occured \(error)")
        }
    }
}
//PreviewClass
class PreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    // MARK: UIView
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}

