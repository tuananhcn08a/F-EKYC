//
//  FEKYC.swift
//  FEKYC
//
//  Created by Ragnar on 8/7/20.
//

import Foundation
import UIKit

enum FEKYCError: Error {
    case error(String)
}

public class FEKYC: NSObject {
    // MARK: Properties
    
    // Interfaces
    public init(config: FEKYCConfig) {
        FEKYCDataManager.shared.config = config
    }
    
    public func start(from viewController: UIViewController, completion: @escaping ([String: Any]?) -> Void) {
           FEKYCDataManager.shared.completion = completion
           
           let storyboard = UIStoryboard(name: "FEKYC", bundle: Bundle(for: FEKYCWelcomeVC.self))
           let welcomeVC = storyboard.instantiateViewController(withIdentifier: "FEKYCWelcomeVC") as? FEKYCWelcomeVC
           viewController.present(welcomeVC!, animated: true, completion: nil)
       }
}
