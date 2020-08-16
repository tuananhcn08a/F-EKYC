//
//  BackendManager.swift
//  UserCardId
//
//  Created by The New Macbook on 7/6/18.
//  Copyright © 2018 FPT. All rights reserved.
//

import UIKit
import Alamofire
import Hydra

class FEKYCBackendManager {
    
    let host = "https://api-demo-ekyc.fpt.ai/"
    let hostCheckAPI = "https://api.fpt.ai/ops/checkapikey"
    let hostLivenessAPI = "https://api.fpt.ai/dmp/checklive/v2"
    
    // Properties
    var apiKey: String! = nil
    
    
    // POST request
    internal var postRequest : NSMutableURLRequest! {
        
        get {
            // Init post request
            let _postRequest = NSMutableURLRequest(url: URL(string: host)!)
            _postRequest.httpMethod = "POST"
            _postRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            _postRequest.setValue("no-cache", forHTTPHeaderField: "cache-control")
            return _postRequest
        }
    }
    
    // MARK: - Singleton
    static let shared = FEKYCBackendManager()
    
    init() {
        byPassSSLCertificate()
    }
    
    // Check api key
    func checkApiKey(apiKey: String, completeHandle: ((Bool) -> ())?) {
        
        let request = NSMutableURLRequest(url: URL(string: hostCheckAPI)!)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        Alamofire.request(request as URLRequest).response { response in
            guard let status = response.response?.statusCode, (status == 200 || status == 301) else {
                completeHandle?(false)
                return
            }
            completeHandle?(true)
        }
    }
    
    func reduceImage(image: UIImage, limitSize: CGFloat = 2.5) -> Data? {
        guard let defaultData = UIImageJPEGRepresentation(image, 1.0) else {
            return nil
        }
        
        let sizeOfImg = CGFloat(defaultData.count) / CGFloat(1024 * 1024)
        if sizeOfImg > limitSize {
            let ratio = limitSize / CGFloat(sizeOfImg)
            return UIImageJPEGRepresentation(image, ratio)
        }
        
        return defaultData
    }
    
    // Upload photo
    func upload(photos: [UIImage], parameters: [String : String] = [:], completeHandle: (() -> ())?) -> Promise<[String: Any]?> {
        
        let request = self.postRequest!
        request.url = URL(string: host + FEKYCDataManager.shared.userState.documentType.endPoint())
        
        request.setValue(apiKey, forHTTPHeaderField: "api_key")
        
        let fullName = FEKYCDataManager.shared.userState.fullName
        
        return Promise<[String: Any]?>(in: .background, { resolve, reject, _  in
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                if (FEKYCDataManager.shared.userState.documentType == .idCard || FEKYCDataManager.shared.userState.documentType == .driveLicense) {

                    if let imageData = self.reduceImage(image: photos[0]) {
                        let fileName = "\(fullName)_\(FEKYCDataManager.shared.userState.documentType.title())_front.jpg"
                        multipartFormData.append(imageData, withName: "front", fileName: fileName, mimeType: "image/jpeg")
                    }
                    if let imageData = self.reduceImage(image: photos[1]) {
                        let fileName = "\(fullName)_\(FEKYCDataManager.shared.userState.documentType.title())_back.jpg"
                        multipartFormData.append(imageData, withName: "back", fileName: fileName, mimeType: "image/jpeg")
                    }
                    if let imageData = self.reduceImage(image: photos[2]) {
                        let fileName = "\(fullName)_\(FEKYCDataManager.shared.userState.documentType.title())_face.jpg"
                        multipartFormData.append(imageData, withName: "face", fileName: fileName, mimeType: "image/jpeg")
                    }
                } else if (FEKYCDataManager.shared.userState.documentType == .passport) {
                    if let imageData = self.reduceImage(image: photos[0]) {
                        let fileName = "\(fullName)_\(FEKYCDataManager.shared.userState.documentType.title())_front.jpg"
                        multipartFormData.append(imageData, withName: "front", fileName: fileName, mimeType: "image/jpeg")
                    }
                    if let imageData = self.reduceImage(image: photos[1]) {
                        let fileName = "\(fullName)_\(FEKYCDataManager.shared.userState.documentType.title())_face.jpg"
                        multipartFormData.append(imageData, withName: "face", fileName: fileName, mimeType: "image/jpeg")
                    }
                }
                
            }, with: (request as URLRequest), encodingCompletion: { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //                        debugPrint(response)
                        print(response.error?.localizedDescription)
                        
                        completeHandle?()
                        
                        let jsonObj = response.result.value as? [String: Any]
                        resolve(jsonObj)
                    }
                case .failure(let encodingError): break
                    //                    print(encodingError)
                }
            })
        })
    }
    
    // Upload liveness video
    func upload(frontDocumentPhoto: UIImage, livenessVideo: URL, parameters: [String : String] = [:], completeHandle: (() -> ())?) -> Promise<[String: Any]?> {
        
        let request = self.postRequest!
        request.url = URL(string: hostLivenessAPI)
        
        request.setValue(apiKey, forHTTPHeaderField: "api_key")
        
        let fullName = FEKYCDataManager.shared.userState.fullName
        
        return Promise<[String: Any]?>(in: .background, { resolve, reject, _  in
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                // liveness video
                if let dataLiveness = NSData(contentsOf: livenessVideo) as Data? {
                    let fileName = "\(fullName)_liveness_video.mp4"
                    multipartFormData.append(dataLiveness, withName: "video", fileName: fileName, mimeType: "mp4")
                }
                
                // photo
                if let imageData = self.reduceImage(image: frontDocumentPhoto) {
                    let fileName = "\(fullName)_\(FEKYCDataManager.shared.userState.documentType.title())_front.jpg"
                    multipartFormData.append(imageData, withName: "cmnd", fileName: fileName, mimeType: "image/jpeg")
                }
                
            }, with: (request as URLRequest), encodingCompletion: { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //                        debugPrint(response)
                        print(response.error?.localizedDescription)
                        
                        completeHandle?()
                        
                        let jsonObj = response.result.value as? [String: Any]
                        resolve(jsonObj)
                    }
                case .failure(let encodingError): break
                    //                    print(encodingError)
                }
            })
        })
    }
    
    // MARK: - Ultilities Methods
    /**
     By pass SSL Certificate
     */
    private func byPassSSLCertificate() {
        let manager = Alamofire.SessionManager.default
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
    }
}
