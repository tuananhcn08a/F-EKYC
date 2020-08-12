//
//  FEKYCBaseAVViewController.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 4/23/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit
import AVFoundation

let ImageMaxSize      = 1       // ảnh ko quá 4Mb//
class FEKYCBaseAVViewController: FEKYCBaseViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var previewView: UIView!
    
    // MARK: - Properties
    
    // Camera View
    var session: AVCaptureSession?
    fileprivate var input: AVCaptureDeviceInput?
    fileprivate var stillImageOutput: AVCaptureStillImageOutput?
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer?.frame = previewView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopCameraPreview()
    }
    // MARK: - Method
    func startCameraPreview(position: AVCaptureDevice.Position = .back) {
        print("FEKYCTakeFrontOfCardIdViewController startCameraPreview")
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        guard let camera = getCameraDevice(position: position) else { return }
        var error: NSError?
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        if error == nil && session!.canAddInput(input!) {
            session!.addInput(input!)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                videoPreviewLayer!.videoGravity = .resizeAspectFill
                videoPreviewLayer!.connection?.videoOrientation = .portrait
                previewView.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
                // ...
                // Configure the Live Preview here...
            }
            // ...
            // The remainder of the session setup will go here...
        }
    }
    
    func stopCameraPreview() {
        print("FEKYCTakeFrontOfCardIdViewController stopCameraPreview")
        session?.stopRunning()
    }
    
    //Get the device (Front or Back)
    func getCameraDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: Array = AVCaptureDevice.devices();
        for de in devices {
            let deviceConverted = de
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    // Capture image from camera
    func capturePhoto(completion: @escaping (UIImage) -> ()) {
        guard let videoConnection = stillImageOutput?.connection(with: .video) else { return }
        stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {[weak self] (sampleBuffer, error) -> Void in
            self?.stopCameraPreview()
            if sampleBuffer != nil, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!) {
                
                let dataProvider = CGDataProvider(data: imageData as CFData)
                let cgImageRef = CGImage.init(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.relativeColorimetric)
                
                DispatchQueue.global().async {
                    
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImage.Orientation.right).compressTo(ImageMaxSize)
                    
                    completion(image)
                    //                    DispatchQueue.main.async {
                    //                        print("start running")
                    //                        self?.session?.startRunning()
                    //                    }
                }
            }
        })
    }
    
    //  Camera position
    //Get the device (Front or Back)
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: Array = AVCaptureDevice.devices()
        for device in devices {
            if(device.position == position){
                return device
            }
        }
        return nil
    }
    // MARK: - Method
    func switchCamera() {
        
        // Get current input
        guard let inputs = session?.inputs, inputs.count > 0, let currentInput = inputs[0] as? AVCaptureDeviceInput else { return }
        
        // Begin new session configuration and defer commit
        session?.beginConfiguration()
        defer {
            session?.commitConfiguration()
        }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if currentInput.device.position == .back {
            newDevice = getCameraDevice(position: .front)
        } else  {
            newDevice = getCameraDevice(position: .back)
        }
        
        // Create new capture input
        guard let nDevice = newDevice, let newDeviceInput = try? AVCaptureDeviceInput(device: nDevice) else {
            return
        }
        
        // Swap capture device input
        session?.removeInput(currentInput)
        session?.addInput(newDeviceInput)
    }
    
    // MARK: - Action
    
    @IBAction func btnFlashClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == .on) {
                    device.torchMode = .off
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
}
