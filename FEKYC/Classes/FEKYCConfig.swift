//
//  FEKYCConfig.swift
//  Alamofire
//
//  Created by Ragnar on 8/7/20.
//

import Foundation

public struct FEKYCConfig {
    public var apiKey: String
    public var fullName: String
    public var orcType: FEKYCOrcType
    public var orcDocumentType: FEKYCOrcDocumentType
    
    public init(apiKey: String, fullName: String, orcType: FEKYCOrcType, orcDocumentType: FEKYCOrcDocumentType) {
        self.apiKey = apiKey
        self.fullName = fullName
        self.orcType = orcType
        self.orcDocumentType = orcDocumentType
    }
}
