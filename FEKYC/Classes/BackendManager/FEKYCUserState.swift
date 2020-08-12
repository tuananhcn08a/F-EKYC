//
//  FEKYCUserState.swift
//  FEKYC
//
//  Created by The New Macbook on 3/12/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit

public enum FEKYCOrcDocumentType {
    case idCard
    case driveLicense
    case passport
    func title() -> String {
        switch self {
        case .idCard:
            return "id"
        case .driveLicense:
            return "driving_license"
        case .passport:
            return "passport"
        }
    }
    
    func endPoint() -> String {
        switch self {
        case .idCard:
            return "check/id"
        case .driveLicense:
            return "check/driving-license"
        case .passport:
            return "check/passport"
        }
    }
}

public enum FEKYCOrcType {
    case photo
    case liveness
    case video
}

struct FEKYCUserState {
    
    // MARK: - Properties
    var fullName: String
    var flowType: FEKYCOrcType
    let uuid = UUID().uuidString
    var documentType: FEKYCOrcDocumentType
    
    // MARK: - Life cycle
    init() {
        fullName = ""
        flowType = .photo
        documentType = .idCard
    }
}
