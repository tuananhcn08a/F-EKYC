//
//  ViewController.swift
//  EKYC_Sample
//
//  Created by Ragnar on 8/12/20.
//  Copyright © 2020 Ragnar. All rights reserved.
//

import UIKit
import FEKYC
import RadioGroup

class ViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: - Outlet
    @IBOutlet weak var tfFullname: UITextField!
    @IBOutlet var orcDocumentTypeGroup: RadioGroup!
    
    @IBOutlet weak var orcTypeGroup: RadioGroup!
    
    @IBOutlet weak var tvResult: UITextView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
        orcDocumentTypeGroup.titles = ["ID Card", "Driver License", "Passport"]
        orcDocumentTypeGroup.addTarget(self, action: #selector(didSelectOrcDocumentTypeOption(radioGroup:)), for: .valueChanged)
        
        orcTypeGroup.titles = ["Photo", "Liveness"]
        orcTypeGroup.addTarget(self, action: #selector(didSelectOrcTypeOption(radioGroup:)), for: .valueChanged)
    }
    
    // MARK: - Action
    @IBAction func btnStartClicked(_ sender: Any) {
        var orcDocumentType = FEKYCOrcDocumentType.idCard
        var orcType = FEKYCOrcType.photo
        
        switch orcDocumentTypeGroup.selectedIndex {
        case 0:
            orcDocumentType = FEKYCOrcDocumentType.idCard
        case 1:
            orcDocumentType = FEKYCOrcDocumentType.driveLicense
        case 2:
            orcDocumentType = FEKYCOrcDocumentType.passport
        default: break
        }
        
        switch orcTypeGroup.selectedIndex {
        case 0:
            orcType = FEKYCOrcType.photo
        case 1:
            orcType = FEKYCOrcType.liveness
        default: break
        }
        
        let config = FEKYCConfig(apiKey: "papFhWBwHBV7RvFx7b0STPAZw0xo7kRJ", fullName: tfFullname.text!, orcType: orcType, orcDocumentType: orcDocumentType)
        let fekyc = FEKYC(config: config)
        fekyc.start(from: self) { [weak self] result in
            self?.tvResult.text = "\(String(describing: result))"
        }
    }
    
    
    @objc func didSelectOrcDocumentTypeOption(radioGroup: RadioGroup) {
        print(radioGroup.titles[radioGroup.selectedIndex] ?? "")
    }

    @objc func didSelectOrcTypeOption(radioGroup: RadioGroup) {
        print(radioGroup.titles[radioGroup.selectedIndex] ?? "")
    }
}

