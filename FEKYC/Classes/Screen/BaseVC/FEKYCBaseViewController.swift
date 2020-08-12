//
//  FEKYCBaseViewController.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 4/22/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit
import MBProgressHUD

class FEKYCBaseViewController: UIViewController {

    // MARK: - Outlet
    
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        
        print("deinit \(type(of: self))")
    }
    // MARK: - Method
    func showAlertView(title: String, message: String, okTitle: String?, cancelTitle: String?, completion:((_ isPressedOK: Bool) -> Swift.Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (okTitle != nil) {
            let okAction = UIAlertAction(title: okTitle, style: .default, handler: { (result: UIAlertAction) in
                print("OK")
                completion?(true)
            })
            
            alert.addAction(okAction)
        }
        
        if (cancelTitle != nil) {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .destructive, handler: { (result: UIAlertAction) in
                print("Cancel")
                completion?(false)
            })
            
            alert.addAction(cancelAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func getIPAddress() -> String {
        var address: String = ""
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                      if let name: String = String(cString: (interface?.ifa_name)!), name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                        print(address)
                     }
                }
            }
            freeifaddrs(ifaddr)
        }
         return address
    }

    // Version & Build number app
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = (dictionary["CFBundleShortVersionString"] as? String) ?? ""
        let build = (dictionary["CFBundleVersion"] as? String) ?? ""
        return "v\(version)_\(build)"
    }
    
    func setBorderDashFor(parentView: UIView, color: CGColor) {
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = color
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = parentView.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: parentView.bounds).cgPath
        parentView.layer.addSublayer(yourViewBorder)
    }
    
//    func submitDocument(lstPhotos: [UIImage], isShowLoading: Bool) {
//
//        let fullName = FEKYCUserState.shared.fullName
//        let _ = async { [weak self] _ -> Void in
//
//            for (index, item) in lstPhotos.enumerated() {
//
//                guard let strongSelf = self else {
//                    return
//                }
//
//                let name = "\(index + 2)_\(fullName)_\(FEKYCUserState.shared.uuid).jpg"
//                let ip = strongSelf.getIPAddress()
//
//                try await(FEKYCBackendManager.shared.upload(photo: item, photoName: name, parameters: ["ip":ip], completeHandle: {
//                    print("Uploaded (\(index + 1)/\(lstPhotos.count))")
//                }))
//            }
//            return
//        }.then({ [weak self] _ in
//            print("finish")
//        })
//
//    }
//
//    func submitSelfie(photo: UIImage, successHandler: (() -> ())?) {
//
//        let fulName = FEKYCUserState.shared.fullName
//
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = MBProgressHUDMode.indeterminate
//        hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.5)
//        hud.label.text = "Uploading"
//
//        let name = "1_\(fulName)_\(FEKYCUserState.shared.uuid).jpg"
//        let ip = self.getIPAddress()
//
//        FEKYCBackendManager.shared.upload(photo: photo, photoName: name, parameters: ["ip":ip], completeHandle:nil)
//            .then { [weak self] response in
//
//                hud.hide(animated: true)
//
//                guard let strongSelf = self else {
//                    return
//                }
//
//                if let error = response?["error"] as? String {
//                    strongSelf.showAlertView(title: "Error", message: error, okTitle: "OK", cancelTitle: nil)
//                    return
//                }
//
//                successHandler?()
//        }.catch { error in
//            self.showAlertView(title: "Error", message: error.localizedDescription, okTitle: "OK", cancelTitle: nil)
//        }
//    }
    
    func submit(photos: [UIImage], successHandler: (([String: Any]?) -> ())?) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.5)
        hud.label.text = "Processing..."
        
        FEKYCBackendManager.shared.upload(photos: photos, completeHandle: nil)
            .then { [weak self] response in
                
                hud.hide(animated: true)
                
                guard let strongSelf = self, let errorCode = response?["code"] as? Int else {
                    return
                }
                
                if errorCode != 200, let message = response?["message"] as? String {
                    strongSelf.showAlertView(title: "Error", message: message, okTitle: "OK", cancelTitle: nil)
                    return
                }
                
                if let dataObj = response?["data"] as? [String: Any] {
                    successHandler?(dataObj)
                }
        }.catch { error in
            self.showAlertView(title: "Error", message: error.localizedDescription, okTitle: "OK", cancelTitle: nil)
        }
    }
    // MARK: Action
    @IBAction func btnBackDismissClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnBackPopClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
