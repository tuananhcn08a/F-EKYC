//
//  FEKYCLivenessVC.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 4/24/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo
import MBProgressHUD
import Hydra

let fileName = "tempLiveness.mp4";

class FEKYCLivenessVC: FEKYCBaseViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("capture did finish")
        print(output);
        print(outputFileURL);
    }
    
    // MARK: - Outlet
    
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var takePhotoView: UIView!
    @IBOutlet weak var lbDirection: UILabel!
    @IBOutlet weak var deleteSelfieView: UIView!
    @IBOutlet weak var descriptionSelfieView: UIView!
    @IBOutlet weak var imgFaceBound: UIImageView!
    @IBOutlet weak var imgDirection: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    
    // -------------
    
    @IBOutlet private weak var cameraView: UIView!
    var successPopup: FEKYCSuccessPopupVC? = nil
    
    // MARK: - Properties
    var lstDocumentPhoto: [UIImage] = []
    
    private var isUsingFrontCamera = true
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: "visiondetector.SessionQueue")
    
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    
    let videoFileOutput = AVCaptureMovieFileOutput()
    
    var selfiePhoto: UIImage? = nil {
        didSet {
            if let imgPhoto = selfiePhoto {
                let lstPhotos = self.lstDocumentPhoto + [imgPhoto]
                FEKYCBackendManager.shared.upload(photos: lstPhotos, completeHandle: nil)
                    .then { [weak self] response in
                        self?.orcResponse = response
                }
            }
        }
    }
    let photoOutput = AVCapturePhotoOutput()
    
    var orcResponse: [String: Any]? = nil
    
    // MARK: COunt down
    let lstImgFaceBound = [
        UIImage(withNamed: "FEKYC_face-inactive"),
        UIImage(withNamed: "FEKYC_face-inactive"),
        UIImage(withNamed: "FEKYC_face-left"),
        UIImage(withNamed: "FEKYC_face-left-success"),
        UIImage(withNamed: "FEKYC_face-down"),
        UIImage(withNamed: "FEKYC_face-down-success"),
        UIImage(withNamed: "FEKYC_face-right"),
        UIImage(withNamed: "FEKYC_face-right-success"),
        UIImage(withNamed: "FEKYC_face-up"),
        UIImage(withNamed: "FEKYC_face-up-success")]
    let lstArrow = [
        UIImage(withNamed: "FEKYC_ic_arrow_up"),
        UIImage(withNamed: "FEKYC_ic_arrow_up"),
        UIImage(withNamed: "FEKYC_ic_arrow_left"),
        UIImage(withNamed: "FEKYC_ic_arrow_left"),
        UIImage(withNamed: "FEKYC_ic_arrow_down"),
        UIImage(withNamed: "FEKYC_ic_arrow_down"),
        UIImage(withNamed: "FEKYC_ic_arrow_right"),
        UIImage(withNamed: "FEKYC_ic_arrow_right"),
        UIImage(withNamed: "FEKYC_ic_arrow_up"),
        UIImage(withNamed: "FEKYC_ic_arrow_up")]
    
    let lstDirection = [
        "Keep Straight",
        "Keep Straight",
        "Turn Left",
        "Turn Left",
        "Turn Down",
        "Turn Down",
        "Turn Right",
        "Turn Right",
        "Turn Up",
        "Turn Up"]
    let lstDescription = [
        "Please keep your face centered",
        "Please keep your face centered",
        "Please turn your face slowly to the left",
        "Please turn your face slowly to the left",
        "Please turn your face slowly to the down",
        "Please turn your face slowly to the down",
        "Please turn your face slowly to the right",
        "Please turn your face slowly to the right",
        "Please turn your face slowly to the up",
        "Please turn your face slowly to the up"]
    var myTimer: Timer = Timer()
    let totalCoundownTime: Int = 20
    let stepCoundownTime: Int = 2
    var counter: Int = 0
    
    func startCountdown(){
        imgFaceBound.image = lstImgFaceBound[0]
        lbDescription.text = lstDescription[0]
        imgDirection.image = lstArrow[0]
        
        myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(stepCoundownTime),
          target: self,
        selector: #selector(self.updateTime),
        userInfo: nil,
         repeats: true)
        
    }
    
    @objc func updateTime() {
        self.counter += self.stepCoundownTime
        
        if self.counter == 2 {
            handleTakePhoto()
        }
        
        if self.counter > 5 && !self.videoFileOutput.isRecording {
            self.videoFileOutput.startRecording(to: self.filePath, recordingDelegate: self)
        }
        //
        let step = self.counter / self.stepCoundownTime
        if step < self.lstImgFaceBound.count {
            self.imgFaceBound.image = self.lstImgFaceBound[step]
        }
        if step < self.lstDescription.count {
            self.lbDescription.text = self.lstDescription[step]
        }
        if step < self.lstDirection.count {
            self.lbDirection.text = self.lstDirection[step]
        }
        if step < self.lstArrow.count {
            self.imgDirection.image = self.lstArrow[step]
        }
        
        //
        if step >= (self.totalCoundownTime / self.stepCoundownTime - 1){
            self.stopCounDown()
        }
    }
    
    func stopCounDown() {
        myTimer.invalidate()
        counter = 0
        videoFileOutput.stopRecording()
        setEnableButtonSubmit(isEnable: true)
        stopSession()
    }
    
    
    // MARK: - Life Cycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.successPopup = self.storyboard?.instantiateViewController(withIdentifier: "FEKYCSuccessPopupVC") as? FEKYCSuccessPopupVC
        self.successPopup?.actionCompletedHandle = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.popToRootViewController(animated: true)
        }
        
        self.cameraView.layer.cornerRadius = (UIScreen.main.bounds.size.width - 100) / 2
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        
        setUpCaptureSessionInput()
        setUpCaptureSessionOutput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startCountdown()
        startSession()
        
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Method
    
    private func setUpCaptureSessionOutput() {
        sessionQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.captureSession.beginConfiguration()
            // When performing latency tests to determine ideal capture settings,
            // run the app in 'release' mode to get accurate performance metrics
            strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.high
            
            let maximumVideoLength = 7; //Whatever value you wish to set as the maximum, in seconds
            let prefferedTimeScale = 30 //Frames per second

            let maxDuration = CMTimeMakeWithSeconds(Float64(maximumVideoLength), Int32(prefferedTimeScale))
            strongSelf.videoFileOutput.maxRecordedDuration = maxDuration
                
            if strongSelf.captureSession.canAddOutput(strongSelf.videoFileOutput) {
                strongSelf.captureSession.addOutput(strongSelf.videoFileOutput)
            }
            
            if strongSelf.captureSession.canAddOutput(strongSelf.photoOutput) {
                strongSelf.captureSession.addOutput(strongSelf.photoOutput)
            }
            strongSelf.captureSession.commitConfiguration()
        }
    }
    
    private func setUpCaptureSessionInput() {
        sessionQueue.async {
            let cameraPosition: AVCaptureDevice.Position = self.isUsingFrontCamera ? .front : .back
            guard let device = self.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                self.captureSession.beginConfiguration()
                let currentInputs = self.captureSession.inputs
                for input in currentInputs {
                    self.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                self.captureSession.addInput(input)
                self.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    func startSession() {
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
            )
            return discoverySession.devices.first { $0.position == position }
        }
        return nil
    }
    
    
    private func setEnableButtonSubmit(isEnable: Bool) {
        self.btnSubmit.isEnabled = isEnable
        self.btnSubmit.backgroundColor = isEnable ? UIColor(hexString: "#F7722F") : UIColor(hexString: "#C7C7CC")
    }
    
    private func handleTakePhoto() {
           let photoSettings = AVCapturePhotoSettings()
           if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
               photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
               photoOutput.capturePhoto(with: photoSettings, delegate: self)
           }
       }
    
    // MARK: - Action
    @IBAction func switchCamera(_ sender: Any) {
        isUsingFrontCamera = !isUsingFrontCamera
        setUpCaptureSessionInput()
    }
    
    @IBAction func btnDeleteSelfieClicked(_ sender: Any) {
        
//        submitView.isHidden = true
        
        setEnableButtonSubmit(isEnable: false)
        deleteSelfieView.isHidden = true
        takePhotoView.isHidden = false
        descriptionSelfieView.isHidden = false
        
        if !self.captureSession.isRunning {
            self.startSession()
        }
        startCountdown()
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.5)
        hud.label.text = "Processing ..."
        
        FEKYCBackendManager.shared.upload(frontDocumentPhoto: self.lstDocumentPhoto[0], livenessVideo: self.filePath, completeHandle: nil)
            .then { [weak self](response) in
                guard let strongSelf = self else {
                    return
                }
                hud.hide(animated: true)
                let result: [String: Any] = ["orcResponse": strongSelf.orcResponse, "livenessResponse": response]
                FEKYCDataManager.shared.completion?(result)
                self?.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        }.catch { [weak self] error in
            self?.showAlertView(title: "Error", message: error.localizedDescription, okTitle: "OK", cancelTitle: nil)
            hud.hide(animated: true)
        }
    }
    
}

extension FEKYCLivenessVC: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // dispose system shutter sound
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingRawPhoto rawSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }

        if  let sampleBuffer = rawSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)

            self.selfiePhoto = image
        } else {
            print("some error here")
        }
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        self.selfiePhoto = UIImage(data: imageData);
    }
}
