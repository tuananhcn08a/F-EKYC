//
//  SuccessPopupVC.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 4/24/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit

class FEKYCSuccessPopupVC: UIViewController {

    // MARK: - Outlet
    
    // MARK: - Properties
    
    var showPopupCompletedHandle: (() -> ())?
    var hidePopupCompletedHandle: (() -> ())?
    var actionCompletedHandle: (() -> ())?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Method
    // show popup with animation type
    func showInView(parent: UIViewController) {
        
        // Add the popup view controller to the top most UIViewController of the application
        parent.addChildViewController(self)
        parent.view.addSubview(view)
        parent.view.endEditing(true)
        
        viewWillAppear(true)
        didMove(toParentViewController: parent)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = parent.view.bounds
        
        showPopupCompletedHandle?()
    }
    
    // hide with completion handle
    func hide(completion: (() -> Void)? = nil) {
        
        self.hidePopupCompletedHandle?()
        
        UIView.animate(withDuration: 1.0) { [weak self] in
            
            self?.view.removeFromSuperview()
            self?.removeFromParentViewController()
        }
        
    }
    
    // MARK: - Action
    @IBAction func btnDoneClicked(_ sender: Any) {
        actionCompletedHandle?()
    }
}
