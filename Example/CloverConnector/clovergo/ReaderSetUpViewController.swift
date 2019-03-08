//
//  ReaderSetUpViewController.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import GoConnector

class ReaderSetUpViewController: UIViewController, StartTransactionDelegate {
    
    @IBOutlet weak var buttonConnect350: UIButton!
    @IBOutlet weak var buttonConnect450: UIButton!
    @IBOutlet weak var labelConnect350: UILabel!
    @IBOutlet weak var labelConnect450: UILabel!
    @IBOutlet weak var buttonKeyed: UIButton!
    @IBOutlet weak var enableQuickChip: UISwitch!
    
    var cloverConnector350Reader : ICloverConnector?
    var cloverConnector450Reader : ICloverConnector?
    var cloverConnectorListener:CloverConnectorListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        checkReaderConnectedStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func action_connect350Button(sender: AnyObject)
    {
        if(!FLAGS.is350ReaderInitialized)
        {
            if(((PARAMETERS.accessToken) != nil) && ((PARAMETERS.apiKey) != nil) && ((PARAMETERS.secret) != nil))
            {
                
                let config350Reader : CloverGoDeviceConfiguration = CloverGoDeviceConfiguration.Builder(apiKey: PARAMETERS.apiKey!, secret: PARAMETERS.secret!, env: .test).accessToken(PARAMETERS.accessToken!).allowAutoConnect(true).allowDuplicateTransaction(false).deviceType(.RP350).enableLogs(true).enableQuickChip(enableQuickChip.isOn).build()
                
                cloverConnector350Reader = CloverGoConnector(config: config350Reader)
                
                cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector350Reader!)
                
                (cloverConnectorListener as? CloverGoConnectorListener)?.addNotificationObservers()
                
                (cloverConnector350Reader as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener: (cloverConnectorListener as? ICloverGoConnectorListener)!)
                (UIApplication.shared.delegate as! AppDelegate).cloverConnectorListener = cloverConnectorListener
                (UIApplication.shared.delegate as! AppDelegate).cloverConnector = cloverConnector350Reader
                cloverConnector350Reader?.initializeConnection()
            }
            else
            {
                let alert = UIAlertController(title: nil, message: "Missing parameters to initialize the SDK", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: nil, message: "Reader 350 is already initialized", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        SHARED.delegateStartTransaction = self
    }
    
    @IBAction func action_connect450Button(sender: AnyObject)
    {
        
        if(!FLAGS.is450ReaderInitialized)
        {
            if(((PARAMETERS.accessToken) != nil) && ((PARAMETERS.apiKey) != nil) && ((PARAMETERS.secret) != nil))
            {

                let config450Reader = CloverGoDeviceConfiguration.Builder(apiKey: PARAMETERS.apiKey!, secret: PARAMETERS.secret!, env: .test).accessToken(PARAMETERS.accessToken!).allowAutoConnect(true).allowDuplicateTransaction(false).enableLogs(true).enableQuickChip(enableQuickChip.isOn).build()

                cloverConnector450Reader = CloverGoConnector(config: config450Reader)
                
                cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector450Reader!)
                
                (cloverConnectorListener as? CloverGoConnectorListener)?.addNotificationObservers()
                
                (cloverConnector450Reader as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener: (cloverConnectorListener as? ICloverGoConnectorListener)!)
                (UIApplication.shared.delegate as! AppDelegate).cloverConnectorListener = cloverConnectorListener
                (UIApplication.shared.delegate as! AppDelegate).cloverConnector = cloverConnector450Reader
                cloverConnector450Reader?.initializeConnection()
            }
            else
            {
                let alert = UIAlertController(title: nil, message: "Missing parameters to initialize the SDK", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: nil, message: "Reader 450 is already initialized", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        SHARED.delegateStartTransaction = self
    }
    
    @IBAction func action_skipButton(sender: AnyObject)
    {
        
        let defaultConfig = CloverGoDeviceConfiguration.Builder(apiKey: PARAMETERS.apiKey!, secret: PARAMETERS.secret!, env: .test).accessToken(PARAMETERS.accessToken!).allowAutoConnect(true).allowDuplicateTransaction(false).enableLogs(true).build()
        cloverConnector450Reader = CloverGoConnector(config: defaultConfig)
        
        cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector450Reader!)
        
        (cloverConnector450Reader as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener: (cloverConnectorListener as? ICloverGoConnectorListener)!)
        (cloverConnectorListener as? CloverGoConnectorListener)?.addNotificationObservers()
        (UIApplication.shared.delegate as! AppDelegate).cloverConnectorListener = cloverConnectorListener
        (UIApplication.shared.delegate as! AppDelegate).cloverConnector = cloverConnector450Reader
        nextVC()
    }
    
    //MARK: SelectReader
    
    func selectedReader(readerInfo: CLVModels.Device.GoDeviceInfo)
    {
        //        dismissViewControllerAnimated(true, completion: nil)
        //        AlertLoading.show("Connecting to \nReader: \(readerInfo.bluetoothName!)")
        //        cloverConnector450Reader?.connectToBluetoothDevice(readerInfo)
    }
    
    //MARK: StartTransactionDelegate delegates
    
    func proceedAfterReaderReady(merchantInfo: MerchantInfo)
    {
        if merchantInfo.deviceInfo?.deviceModel == "RP350X"
        {
            FLAGS.is350ReaderInitialized = true
            checkReaderConnectedStatus()
        }
        if merchantInfo.deviceInfo?.deviceModel == "RP450X"
        {
            FLAGS.is450ReaderInitialized = true
            checkReaderConnectedStatus()
        }
        
        nextVC()
    }
    
    func nextVC()
    {
        SHARED.workingQueue.async() {
            Thread.sleep(forTimeInterval: 2)
            DispatchQueue.main.async {
//                self.selectInitializedReader()
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabControllerID") as! TabBarController
                self.present(nextViewController, animated:true, completion:nil)
            }
        }
    }
    
    func readerDisconnected()
    {
        FLAGS.is350ReaderInitialized = false
        FLAGS.is450ReaderInitialized = false
        checkReaderConnectedStatus()
    }
    
    func checkReaderConnectedStatus()
    {
        if FLAGS.is350ReaderInitialized{
            labelConnect350.text = "Reader 350 connected ✅"
            buttonConnect350.setTitle("Disconnect", for: .normal)
        }
        else{
            labelConnect350.text = "No 350 Reader connected"
            buttonConnect350.setTitle("Connect", for: .normal)
        }
        if FLAGS.is450ReaderInitialized{
            labelConnect450.text = "Reader 450 connected ✅"
            buttonConnect450.setTitle("Disconnect", for: .normal)
        }
        else{
            labelConnect450.text = "No 450 Reader connected"
            buttonConnect450.setTitle("Connect", for: .normal)
        }
    }

}
