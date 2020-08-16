//
//  FEKYCWelcomeVC.swift
//  FEKYC
//
//  Created by Ragnar on 8/7/20.
//

import UIKit

class FEKYCWelcomeVC: FEKYCBaseViewController {

    // MARK: - Properties
    var apiKey: String! = nil
//    var isKeyValid: Bool = false {
//        didSet {
//            self.btnNext.isHidden = !isKeyValid
//            self.checkAPIKeyDescripntionView.isHidden = isKeyValid
//        }
//    }
//
    // MARK: - Outlet
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var checkAPIKeyDescripntionView: UIView!
    @IBOutlet weak var btnNext: UIButton!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.lbVersion.text = self.version()
        checkAPIKey(apiKey: FEKYCDataManager.shared.config.apiKey)
    }
    
    // MARK: - Action
    
    // MARK: - Method
    func checkAPIKey(apiKey: String) {
        FEKYCBackendManager.shared.checkApiKey(apiKey: apiKey) { [weak self] isValid in
            
            guard let strongSelf = self else {
                return
            }
            
            if isValid {
//                strongSelf.btnNext.isHidden = false
//                strongSelf.checkAPIKeyDescripntionView.isHidden = true
                strongSelf.performSegue(withIdentifier: "navigateToMainFlow", sender: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "API Key is invalid", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { [weak strongSelf] _ in
                    strongSelf?.dismiss(animated: true, completion: nil)
                }))
                strongSelf.show(alert, sender: nil)
            }
        }
    }

}
