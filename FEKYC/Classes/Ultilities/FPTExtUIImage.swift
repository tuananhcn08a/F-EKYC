//
//  FPTExtUIImage.swift
//  FEKYC
//
//  Created by The New Macbook on 3/5/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit

extension UIImage {
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInMb:Int) -> UIImage {
        
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        print(sizeInBytes)
        print("\(UIImageJPEGRepresentation(self, 1.0)?.count)")
        guard let imgData = UIImageJPEGRepresentation(self, 1.0), imgData.count > sizeInBytes else {
            print("return 1")
            return self
        }
        
        let imgSize = imgData.count
        let ratio = CGFloat(sizeInBytes) / CGFloat(imgSize)
        guard let resizeData = UIImageJPEGRepresentation(self, ratio), let resizedImg = UIImage(data: resizeData) else {
            print("return 2")
            return self
        }
        print("ratio \(ratio) after \(CGFloat(sizeInBytes/imgSize)) new size: \(resizeData.count / (1024 * 1024))")
        return resizedImg
    }
    
    convenience init(withNamed named: String) {
        self.init(named: named, in: Bundle(for: FEKYC.self), compatibleWith: nil)!
    }
}
