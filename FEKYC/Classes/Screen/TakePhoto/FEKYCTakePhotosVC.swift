//
//  FEKYCTakePhotosVC.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 4/23/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit
import AVFoundation
import IDMPhotoBrowser
import MBProgressHUD
import Hydra

let cardIdPhotoNumber = 2
fileprivate let unHighlightColor = UIColor(red: 136.0/255.0, green: 138.0/255.0, blue: 154.0/255.0, alpha: 1.0)

class FEKYCTakePhotosVC: FEKYCBaseAVViewController {
    
    // MARK: - Outlet
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var takePhotoContainer: UIView!
    @IBOutlet weak var btnNextAction: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    
    
    // MARK: - Properties
    fileprivate var lstCardIdPhoto: Array<UIImage?> = Array(repeating: nil, count: cardIdPhotoNumber)
    
    // MARK: - Life Cycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbTitle.isHidden = FEKYCDataManager.shared.userState.documentType == .passport
        let btnTitle = FEKYCDataManager.shared.userState.flowType == .liveness ? "LIVENESS" : "TAKE SELFIE"
        if FEKYCDataManager.shared.userState.documentType == .passport {
            lstCardIdPhoto = Array(repeating: nil, count: 1)
        }
        self.btnNextAction.setTitle(btnTitle, for: .normal)
        startCameraPreview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photos = self.lstCardIdPhoto.filter { $0 != nil } as! [UIImage]
        if segue.identifier == "showTakeSelfieVC", let destinationVC = segue.destination as? FEKYCTakeSelfieVC {
            destinationVC.lstDocumentPhoto = photos
        } else if segue.identifier == "showLivenessVC", let destinationVC = segue.destination as? FEKYCLivenessVC {
            destinationVC.lstDocumentPhoto = photos
        }
    }
    
    // MARK: - Action
    @IBAction func btnCameraSwitchClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switchCamera()
    }
    
    @IBAction func btnTakePhotoClicked(_ sender: Any) {
        handleTakePhoto()
    }
    
    @IBAction func btnGalleryClicked(_ sender: Any) {
    }
    
    @IBAction func btnNextStepClicked(_ sender: Any) {
        if FEKYCDataManager.shared.userState.flowType == .liveness {
            
            performSegue(withIdentifier: "showLivenessVC", sender: nil)
        } else if FEKYCDataManager.shared.userState.flowType == .photo {

            performSegue(withIdentifier: "showTakeSelfieVC", sender: nil)
        }
    }
    
    // MARK: Methods
    //  take selfie photo
    private func handleTakePhoto() {
        
        if lstCardIdPhoto.filter({ $0 == nil }).count == 0  {
            return
        }
         
        showIndicatorInCell()
        
        capturePhoto {[weak self] image in
            DispatchQueue.main.async {
                self?.updateListPhotoWith(images: [image.compressTo(ImageMaxSize)])
            }
        }
    }
    
    private func updateListPhotoWith(images: [UIImage]) {
        for image in images {
            
            for index in 0...(self.lstCardIdPhoto.count - 1) {
                if self.lstCardIdPhoto[index] == nil {
                    self.lstCardIdPhoto[index] = image
                    break
                }
            }
        }
        
        handleDisplay()
        
        DispatchQueue.main.async {
            self.photoCollectionView.reloadData()
        }
    }
    
    private func handleDisplay() {
        DispatchQueue.main.async {
            let canNext = self.lstCardIdPhoto.filter({ $0 == nil}).count == 0
            self.btnNextAction.isHidden = !canNext
            self.takePhotoContainer.isHidden = !self.btnNextAction.isHidden
            
            if canNext == true && self.session?.isRunning == true {
                self.stopCameraPreview()
            } else if canNext == false && self.session?.isRunning == false {
                self.session?.startRunning()
            }
        }
    }
    
    private func showIndicatorInCell() {
        
        for (index, item) in lstCardIdPhoto.enumerated() {
            if item == nil, index < self.photoCollectionView.numberOfItems(inSection: 0) {
                let cell = self.photoCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as! FEKYCPhotoCell
                cell.lbPhotoTitle.isHidden = true
                cell.loadingIndicator.startAnimating()
                break
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
}

extension FEKYCTakePhotosVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lstCardIdPhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FEKYCPhotoCell", for: indexPath) as! FEKYCPhotoCell
        
        cell.indexPath = indexPath
        cell.delegate = self
        cell.lbPhotoTitle.text = indexPath.row == 0 ? "front" : "back"
        
        cell.containerView.layer.borderWidth = 1.0
        if (indexPath.row == 0 && lstCardIdPhoto[0] == nil) || (indexPath.row == 1 && lstCardIdPhoto[1] == nil && lstCardIdPhoto[0] != nil){
            cell.lbPhotoTitle.textColor = .white
            cell.containerView.layer.borderColor = UIColor.white.cgColor
        } else {
            cell.lbPhotoTitle.textColor = unHighlightColor
            cell.containerView.layer.borderColor = unHighlightColor.cgColor
        }
        
        guard let currentImage = lstCardIdPhoto[indexPath.row] else {
            cell.btnDelete.isHidden = true
            return cell
        }
        cell.containerView.layer.borderWidth = 0.0
        cell.imgPhoto.image = currentImage
        cell.btnDelete.isHidden = false
        cell.loadingIndicator.stopAnimating()
        cell.lbPhotoTitle.isHidden = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSizeWidth = UIScreen.main.bounds.size.width
        let itemWidth = (screenSizeWidth - 40) / 4
        let itemHeight = collectionView.frame.size.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let screenSizeWidth = UIScreen.main.bounds.size.width
        let itemWidth = (screenSizeWidth - 40) / 4
        let totalCellWidth = CGFloat(lstCardIdPhoto.count) * itemWidth
        let totalSpacingWidth = CGFloat(20 * (lstCardIdPhoto.count - 1))
        
        let horizontalInset = (collectionView.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= lstCardIdPhoto.count || lstCardIdPhoto[indexPath.row] == nil {
            showGallery()
            return
        }
        
        let lstPhoto = lstCardIdPhoto.filter { $0 != nil }
            .map { IDMPhoto(image: $0!) }
        
        guard let photoBrowser = IDMPhotoBrowser(photos: lstPhoto, animatedFrom: collectionView) else { return }
        
        self.present(photoBrowser, animated: true, completion: nil)
    }
}

extension FEKYCTakePhotosVC: FEKYCPhotoCellDelegate {
    func btnDeletePhotoInCellClicked(at index: IndexPath) {
        let indexRow = index.row
        if indexRow < 0 || indexRow >= lstCardIdPhoto.count { return }
        lstCardIdPhoto[indexRow] = nil
        handleDisplay()
        photoCollectionView.reloadData()
    }
}

extension FEKYCTakePhotosVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: UIImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        showIndicatorInCell()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            DispatchQueue.global().async {
                
                self.updateListPhotoWith(images: [image.compressTo(ImageMaxSize)])
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
