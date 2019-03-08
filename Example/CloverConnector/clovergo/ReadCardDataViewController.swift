//
//  ReadCardDataViewController.swift
//  CloverConnector_Example
//
//  Created by Veeramani, Rajan on 3/21/18.
//

import UIKit
import GoConnector

class ReadCardDataViewController: UIViewController {

    @IBOutlet weak var cardDataTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnectorListener?.viewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func readCardData(_ sender: Any) {
        self.cardDataTextView.text = ""
        (UIApplication.shared.delegate as! AppDelegate).cloverConnector?.readCardData(ReadCardDataRequest())
    }
    
}
