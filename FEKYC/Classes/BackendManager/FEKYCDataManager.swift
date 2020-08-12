//
//  FEKYCDataManage.swift
//  FEKYC
//
//  Created by Ragnar on 8/7/20.
//

import UIKit

struct FEKYCDataManager {
    
    // MARK: Properties
    var config: FEKYCConfig! = nil {
        didSet {
            self.userState.fullName = config.fullName
            self.userState.flowType = config.orcType
            self.userState.documentType = config.orcDocumentType
            FEKYCBackendManager.shared.apiKey = config.apiKey
        }
    }
    var userState: FEKYCUserState
    
    var completion: (([String: Any]?) -> Void)? = nil
    
    // MARK: - Singleton
    static var shared = FEKYCDataManager()
    
    init() {
        self.userState = FEKYCUserState()
    }
    
}
