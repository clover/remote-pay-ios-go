//
//  DisconnectReaderViewController.swift
//  CloverConnector_Example
//
//  Created by Veeramani, Rajan (Non-Employee) on 11/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import GoConnector

let disconnectedNotificationKey = "com.connector.disconnect"

class DisconnectReaderViewController: UIViewController {

    @IBOutlet weak var serialNo: UILabel!
    let disconnectedNotificationName = Notification.Name(rawValue: disconnectedNotificationKey)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let merchantInfo = ((UIApplication.shared.delegate as? AppDelegate)?.cloverConnectorListener as? CloverGoConnectorListener)?.merchantInfo {
            serialNo.text = merchantInfo.deviceInfo?.deviceSerial
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        DispatchQueue.main.async {[weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.view.isHidden = true
//            let alertController = UIAlertController(title: "Disconnect Reader", message: "", preferredStyle: .alert)
//            
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
//                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.disconnectDevice()
//                FLAGS.is350ReaderInitialized = false
//                FLAGS.is450ReaderInitialized = false
//                strongSelf.showNextVC()
//            }))
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
//                strongSelf.navigationController?.popViewController(animated: true)
//            }))
//            strongSelf.present(alertController, animated: true, completion: nil)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disconnectReader(_ sender: Any) {
        if (!FLAGS.is450ReaderInitialized && !FLAGS.is350ReaderInitialized)
        {
            self.showNextVC()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(proceedAfterDeviceDisconnected), name: disconnectedNotificationName, object: nil)

            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.disconnectDevice()
            FLAGS.is350ReaderInitialized = false
            FLAGS.is450ReaderInitialized = false
    }
    
    @objc func proceedAfterDeviceDisconnected()
    {
        SHARED.workingQueue.async() {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.async {
                self.showNextVC()
            }
        }
        self.showMessage("Disconnected")
    }
    
    func showNextVC()
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "readerSetUpViewControllerID") as! ReaderSetUpViewController
        self.present(nextViewController, animated:true, completion:nil)
    }

    private func showMessage(_ message:String, duration:Int = 3) {
        
        DispatchQueue.main.async {
            let alertView:UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alertView.show()
            self.perform(#selector(self.dismissMessage), with: alertView, afterDelay: TimeInterval(duration))
        }
        
    }
    
    @objc private func dismissMessage(_ view:UIAlertView) {
        view.dismiss( withClickedButtonIndex: -1, animated: true);
    }
}
