//
//  ViewController.swift
//  FEKYC
//
//  Created by anhdt64 on 08/07/2020.
//  Copyright (c) 2020 anhdt64. All rights reserved.
//

import UIKit
import FEKYC

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnClicked(_ sender: Any) {
        let config = FEKYCConfig(apiKey: "papFhWBwHBV7RvFx7b0STPAZw0xo7kRJ", fullName: "Tuan Anh", orcType: FEKYCOrcType.liveness, orcDocumentType: FEKYCOrcDocumentType.idCard)
        let fekyc = FEKYC(config: config)
        fekyc.start(from: self) { [weak self] result in
            
        }
    }
}

