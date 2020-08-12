//
//  FEKYCTakeSelfieVC.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 4/23/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit
import AVFoundation

class FEKYCTakeSelfieVC: FEKYCBaseAVViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var takePhotoView: UIView!
    @IBOutlet weak var deleteSelfieView: UIView!
    @IBOutlet weak var descriptionSelfieView: UIView!
    
    // MARK: - Properties
    
    var lstDocumentPhoto: [UIImage] = []
    var selfiePhoto: UIImage? = nil {
        didSet {
            let isSelfied = selfiePhoto != nil
            submitView.isHidden = !isSelfied
            deleteSelfieView.isHidden = !isSelfied
            takePhotoView.isHidden = isSelfied
            descriptionSelfieView.isHidden = isSelfied
            if isSelfied == true && session?.isRunning == true {
                self.stopCameraPreview()
            } else if isSelfied == false && session?.isRunning == false {
                self.session?.startRunning()
            }
        }
    }
    
    var successPopup: FEKYCSuccessPopupVC? = nil
    
    // MARK: - Life Cycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startCameraPreview(position: .front)
        self.successPopup = self.storyboard?.instantiateViewController(withIdentifier: "FEKYCSuccessPopupVC") as! FEKYCSuccessPopupVC
        self.successPopup?.actionCompletedHandle = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Method
    //  take selfie photo
    private func handleTakePhoto() {
        
        if selfiePhoto != nil  {
            return
        }
        
        // Show loading indicator
        
        //
        capturePhoto {[weak self] image in
            DispatchQueue.main.async {
                self?.selfiePhoto = image.compressTo(ImageMaxSize)
            }
        }
    }
    
    private func showGallery() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Action
    @IBAction func btnCameraSwitchClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switchCamera()
    }
    
    @IBAction func btnTakePhotoClicked(_ sender: Any) {
        handleTakePhoto()
    }
    
    @IBAction func btnDeleteSelfieClicked(_ sender: Any) {
        self.selfiePhoto = nil
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        guard let photo = self.selfiePhoto else {
            return
        }
        
        let lstPhotos = lstDocumentPhoto + [photo]
        
        self.submit(photos: lstPhotos) { [weak self] response in
            guard let strongSelf = self, let result = response else {
                return
            }
            
//            strongSelf.successPopup!.showInView(parent: strongSelf)
            let resultView = strongSelf.storyboard?.instantiateViewController(withIdentifier: "FEKYCResultVC") as! FEKYCResultVC
            resultView.lstPhoto = lstPhotos
            resultView.result = result
            strongSelf.show(resultView, sender: nil)
            
        }
    }
}

extension FEKYCTakeSelfieVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: UIImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            DispatchQueue.global().async {
                self.selfiePhoto = image.compressTo(ImageMaxSize)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
