//
//  FEKYCResultVC.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 5/21/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class FEKYCResultVC: FEKYCBaseViewController {

    // MARK: - Outlet
    @IBOutlet weak var lbResult: UILabel!
    @IBOutlet weak var contentScrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var lbFaceMatch: UILabel!
    @IBOutlet weak var lbLiveness: UILabel!
    @IBOutlet weak var lbId: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDob: UILabel!
    @IBOutlet weak var lbhome: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbSex: UILabel!
    @IBOutlet weak var lbNationality: UILabel!
    @IBOutlet weak var lbDoe: UILabel!
    @IBOutlet weak var lbEthnicity: UILabel!
    @IBOutlet weak var lbReligion: UILabel!
    @IBOutlet weak var lbFeatures: UILabel!
    @IBOutlet weak var lbIssueDate: UILabel!
    @IBOutlet weak var lbIssueLocation: UILabel!
    
    @IBOutlet weak var livenessVCHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var idVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dobVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sexVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nationalityVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doeVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ethnicityVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var religionVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var featureVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var issueDateVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var issueLocationVHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var lstPhoto: [UIImage] = []
    var result: [String: Any]? = nil
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showResult()
        livenessVCHeightConstraint.constant = FEKYCDataManager.shared.userState.flowType == .liveness ? 50 : 0
    }
    
    override func viewDidLayoutSubviews() {
        contentScrollView.contentSizeToFit()
    }
    
    // MARK: - Method
    fileprivate func showResult() {
        
        guard let sResult = result else {
            return
        }
        
        var errorMessage: String = ""

        if let facematch = sResult["facematch"] as? [String: Any] {
            
            if let code = facematch["code"] as? Int,
                code != 200,
                let message = facematch["message"] as? String {
                errorMessage += message
            }
            
            if let facematchData = facematch["data"] as? [String: Any],
                let isMatch = facematchData["isMatch"] as? Bool,
                let similarity = facematchData["similarity"] as? Double {
                self.lbFaceMatch.text = String(format:"%.1f%%", similarity)
                self.lbFaceMatch.textColor = isMatch ? UIColor(hexString: "#2ecc71") : UIColor(hexString: "#e55039")
                self.lbResult.textColor = isMatch ? UIColor(hexString: "#2ecc71") : UIColor(hexString: "#e55039")
                errorMessage = isMatch == true ? "Success" : "Fail"
            }
        }
        
        if let front = sResult["front"] as? [String: Any] {
            
            if let code = front["errorCode"] as? Int,
                code != 0,
                let message = front["errorMessage"] as? String {
                errorMessage = errorMessage.count > 0 ? errorMessage + "\n" + message : errorMessage + message
            }
            
            guard let frontData = front["data"] as? [String: Any] else {
                return
            }
            // ID number
            self.lbId.text = FEKYCDataManager.shared.userState.documentType != .passport
                ? (frontData["id"] as? String) ?? ""
                : (frontData["passport_number"] as? String) ?? ""
            self.idVHeightConstraint.constant = self.lbId.text!.count > 0 ? 50 : 0
            
            // Name
            self.lbName.text = (frontData["name"] as? String) ?? ""
            self.nameVHeightConstraint.constant = self.lbName.text!.count > 0 ? 50 : 0
            
            // Dob
            self.lbDob.text = (frontData["dob"] as? String) ?? ""
            self.dobVHeightConstraint.constant = self.lbDob.text!.count > 0 ? 50 : 0
            
            // Home
            self.lbhome.text = (frontData["home"] as? String) ?? ((frontData["pob"] as? String) ?? "")
            self.homeVHeightConstraint.constant = self.lbhome.text!.count > 0 ? 50 : 0
            
            // Address
            self.lbAddress.text = (frontData["address"] as? String) ?? ((frontData["pob"] as? String) ?? "")
            self.addressVHeightConstraint.constant = self.lbAddress.text!.count > 0 ? 50 : 0
            
            // Sex
            self.lbSex.text = (frontData["sex"] as? String) ?? ""
            self.sexVHeightConstraint.constant = self.lbSex.text!.count > 0 ? 50 : 0
            
            // Nationality
            self.lbNationality.text = (frontData["nationality"] as? String) ?? ((frontData["nation"] as? String) ?? "")
            self.nationalityVHeightConstraint.constant = self.lbNationality.text!.count > 0 ? 50 : 0
            
            // Doe
            self.lbDoe.text = (frontData["doe"] as? String) ?? ((frontData["nation"] as? String) ?? "")
            self.doeVHeightConstraint.constant = self.lbDoe.text!.count > 0 ? 50 : 0
            
            
        }
        
        if let back = sResult["back"] as? [String: Any] {
            
            if let code = back["errorCode"] as? Int,
                code != 0,
                let message = back["errorMessage"] as? String {
                errorMessage = errorMessage.count > 0 ? errorMessage + "\n" + message : errorMessage + message
            }
            
            guard let backData = back["data"] as? [String: Any] else {
                return
            }
            // Ethnicity
            self.lbEthnicity.text = (backData["ethnicity"] as? String) ?? ""
            self.ethnicityVHeightConstraint.constant = self.lbEthnicity.text!.count > 0 ? 50 : 0
            
            // Ethnicity
            self.lbReligion.text = (backData["religion"] as? String) ?? ""
            self.religionVHeightConstraint.constant = self.lbReligion.text!.count > 0 ? 50 : 0
            
            // Feature
            self.lbFeatures.text = (backData["features"] as? String) ?? ""
            self.featureVHeightConstraint.constant = self.lbFeatures.text!.count > 0 ? 50 : 0
            
            // Issue date
            self.lbIssueDate.text = (backData["issue_date"] as? String) ?? ""
            self.issueDateVHeightConstraint.constant = self.lbIssueDate.text!.count > 0 ? 50 : 0
            
            // Issue Location
            self.lbIssueLocation.text = (backData["issue_loc"] as? String) ?? ""
            self.issueLocationVHeightConstraint.constant = self.lbIssueLocation.text!.count > 0 ? 50 : 0
        }
        
        self.lbResult.text = errorMessage
        
    }
    // MARK: - Action
    @IBAction func btnDoneClicked(_ sender: Any) {
        FEKYCDataManager.shared.completion?(result)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension FEKYCResultVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lstPhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FEKYCResultPhotoCell", for: indexPath) as! FEKYCResultPhotoCell
        
        cell.imgPhoto.image = lstPhoto[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSizeWidth = UIScreen.main.bounds.size.width
        let itemWidth = (screenSizeWidth - CGFloat(lstPhoto.count) + 1) / CGFloat(lstPhoto.count)
        let itemHeight = collectionView.frame.size.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        let screenSizeWidth = UIScreen.main.bounds.size.width
//        let itemWidth = screenSizeWidth / CGFloat(lstPhoto.count)
//        let totalCellWidth = CGFloat(lstPhoto.count) * itemWidth
//        let totalSpacingWidth = CGFloat(20 * (lstPhoto.count - 1))
//
//        let horizontalInset = (collectionView.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//
//        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
