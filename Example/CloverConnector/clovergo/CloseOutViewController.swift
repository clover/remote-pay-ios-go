//
//  CloseOutViewController.swift
//  CloverConnector
//
//  Created by Deshmukh, Harish (Non-Employee) on 9/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import GoConnector


class CloseOutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func closeOut(_ sender: UIButton) {
        let closeOutRequestObj = CloseoutRequest(allowOpenTabs: false, batchId: nil)
        (UIApplication.shared.delegate as! AppDelegate).cloverConnector?.closeout(closeOutRequestObj)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
