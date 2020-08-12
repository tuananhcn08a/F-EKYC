//
//  FEKYCPhotoCell.swift
//  SampleUIFLow
//
//  Created by The New Macbook on 4/23/20.
//  Copyright © 2020 fpt. All rights reserved.
//

import UIKit
protocol FEKYCPhotoCellDelegate: AnyObject {
    func btnDeletePhotoInCellClicked(at index: IndexPath)
}

class FEKYCPhotoCell: UICollectionViewCell {
    
    var indexPath: IndexPath?
    weak var delegate: FEKYCPhotoCellDelegate?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lbPhotoTitle: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        imgPhoto.image = nil
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        guard let index = self.indexPath else {
            return
        }
        
        delegate?.btnDeletePhotoInCellClicked(at: index)
    }
}
