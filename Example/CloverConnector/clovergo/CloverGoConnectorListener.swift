//
//  CloverGoConnectorListener.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import GoConnector

class CloverGoConnectorListener : CloverConnectorListener, ICloverGoConnectorListener, UITextFieldDelegate {
    
    var merchantInfo : MerchantInfo?
    var alertController : UIAlertController?
    
    func onSendReceipt() {
        
        if let ac = self.viewController?.presentedViewController as? UIAlertController {
            if !ac.isBeingDismissed && !ac.isBeingPresented {
                ac.dismiss(animated: true, completion: {
                    self.showReceiptAlertController()
                })
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
                    self.showReceiptAlertController()
                })
            }
        } else {
            self.showReceiptAlertController()
        }
        
        
    }
    
    func showReceiptAlertController() {
        let alertController = UIAlertController(title: "Send Receipt \nTo", message: "email / phone number", preferredStyle: .alert)
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("ra.dummy@xyz.com", comment: "email")
        }
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("555555555", comment: "phone")
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .default, handler: {(action: UIAlertAction) -> Void in
            let email = alertController.textFields?.first!
            let phone = alertController.textFields?.last!
            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.sendReceipt(email: email?.text, phone: phone?.text)
            self.nextVC()
            //            topController.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.sendReceipt(email: nil, phone: nil)
            self.nextVC()
            //            topController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.viewController?.present(alertController, animated:true, completion:nil)
    }
    
    func nextVC() {
        if let vc = self.viewController {
            if vc is SignatureCloverGoViewController {
                var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
                while ((topController.presentedViewController) != nil) {
                    topController = topController.presentedViewController!
                }
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabControllerID") as! TabBarController
                topController.present(nextViewController, animated:true, completion:nil)
            }
        }
    }
    
    func onSignatureRequired() {
        if let ac = self.viewController?.presentedViewController as? UIAlertController {
            ac.dismiss(animated: false, completion: {
                self.viewController?.performSegue(withIdentifier: "signatureCloverGoViewControllerID", sender: nil)
            })
        } else {
            self.viewController?.performSegue(withIdentifier: "signatureCloverGoViewControllerID", sender: nil)
        }
    }
    
    
    func onAidMatch(cardApplicationIdentifiers:[CLVModels.Payments.CardApplicationIdentifier]) -> Void {
        let choiceAlert = UIAlertController(title: "Choose Application Identifier", message: "Please select one of the appId's", preferredStyle: .actionSheet)
        for appId in cardApplicationIdentifiers {
            let action = UIAlertAction(title: appId.applicationLabel, style: .default, handler: {
                (action:UIAlertAction) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.selectCardApplicationIdentifier(cardApplicationIdentier: appId)
                
            })
            choiceAlert.addAction(action)
        }
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action:UIAlertAction) in
            
        }))
        //        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        //        while ((topController.presentedViewController) != nil) {
        //            topController = topController.presentedViewController!
        //        }
        
        if let popoverController = choiceAlert.popoverPresentationController, let viewController = self.viewController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
        }
        
        self.viewController?.present(choiceAlert, animated:true, completion:nil)
    }
    
    func onDevicesDiscovered(devices:[CLVModels.Device.GoDeviceInfo]) ->Void {
        print("Discovered Readers...")
        let choiceAlert = UIAlertController(title: "Choose your reader", message: "Please select one of the reader", preferredStyle: .actionSheet)
        for device in devices {
            let action = UIAlertAction(title: device.deviceName, style: .default, handler: {
                (action:UIAlertAction) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.connectToBluetoothDevice(deviceInfo: device)
                
            })
            choiceAlert.addAction(action)
        }
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action:UIAlertAction) in
            
        }))
        
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        
        if let popoverController = choiceAlert.popoverPresentationController {
            popoverController.sourceView = topController.view
            popoverController.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
        }
        
        topController.present(choiceAlert, animated:true, completion:nil)
        
    }
    
    func onTransactionProgress(event: CLVModels.Payments.GoTransactionEvent) -> Void {
        print("\(event.getDescription())")
        
        switch event
        {
        case .EMV_CARD_INSERTED:
            showMessage("Keep Card Inserted", duration: 1)
            break
        case .CARD_SWIPED:
            showMessage("Card Swiped - Processing Transaction", duration: 1)
        case .CARD_TAPPED:
            showMessage("Card Tapped - Processing Transaction", duration: 1)
        case .PROCESSING_TRANSACTION:
            showMessage("Processing Transaction", duration: 1)
        case .EMV_CARD_REMOVED:
            //            showMessage("Card removed", duration: 1)
            break
            
        case .EMV_CARD_DIP_FAILED:
            showMessage("Emv card dip failed.\nPlease reinsert card", duration: 1)
            break
            
        case .EMV_CARD_SWIPED_ERROR:
            showMessage("Emv card swiped error", duration: 1)
            break
            
        case .EMV_DIP_FAILED_PROCEED_WITH_SWIPE:
            showMessage("Emv card dip failed.\n\nPlease try swipe.", duration: 1)
            break
            
        case .SWIPE_FAILED:
            showMessage("Swipe failed", duration: 1)
            break
            
        case .CONTACTLESS_FAILED_TRY_AGAIN:
            showMessage("Contactless failed\nTry again", duration: 1)
            break
            
        case .SWIPE_DIP_OR_TAP_CARD:
            showMessage("Please \n\nINSERT / SWIPE / TAP \n\na card", duration: 1)
            break
        case .REMOVE_CARD:
            showMessage("Please Remove Card from Reader", duration: 1)
        case .CONTACTLESS_FAILED_TRY_CONTACT:
            showMessage(event.getDescription(), duration: 2)
        case .MULTIPLE_CONTACTLESS_CARDS_DETECTED:
            showMessage(event.getDescription(), duration: 2)
        case .PLEASE_SEE_PHONE:
            showMessage(event.getDescription(), duration: 2)
            
        }
    }
    
    @objc private func dismissMessage1(_ alertController:UIAlertController) {
        if (self.viewController?.presentedViewController as? UIAlertController) != nil {
            alertController.dismiss(animated: false, completion: nil)
        }
    }
    
    private func showMessage(_ message:String, duration:Int = 3) {
        DispatchQueue.main.async {
            if let vc = self.viewController {
                if let ac = self.viewController?.presentedViewController as? UIAlertController {
                    ac.dismiss(animated: false, completion: {
                        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                        vc.present(alertController, animated: false, completion: nil)
                        self.perform(#selector(self.dismissMessage1), with: alertController, afterDelay: TimeInterval(duration))
                    })
                } else {
                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                    vc.present(alertController, animated: false, completion: nil)
                    self.perform(#selector(self.dismissMessage1), with: alertController, afterDelay: TimeInterval(duration))
                }
            }
        }
    }
    
    override func onDeviceReady(_ merchantInfo: MerchantInfo) {
        super.onDeviceReady(merchantInfo)
        self.merchantInfo = merchantInfo
        DispatchQueue.main.async {
            SHARED.delegateStartTransaction?.proceedAfterReaderReady(merchantInfo: merchantInfo)
        }
    }
    
    func onMultiplePaymentModesAvailable(paymentModes: [CLVModels.Payments.PaymentMode]) {
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        for paymentMode in paymentModes {
            let paymentAction = UIAlertAction(title: paymentMode.toString(), style: .default, handler: { (action: UIAlertAction!) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.selectPaymentMode(paymentMode: paymentMode)
            })
            alert.addAction(paymentAction)
        }
        
        topController.present(alert, animated: true, completion: nil)
    }
    
    func onKeyedCardDataRequired() {
        //        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        //        while ((topController.presentedViewController) != nil) {
        //            topController = topController.presentedViewController!
        //        }
        let alertController = UIAlertController(title: "Enter Credit Card Info", message: "", preferredStyle: .alert)
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = NSLocalizedString("Card No", comment: "Card No")
            textField.tag = 1
            textField.delegate = self
        }
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("CVV", comment: "CVV")
            textField.keyboardType = .numberPad
            textField.tag = 2
            textField.delegate = self
        }
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("MMYY", comment: "Expiry date")
            textField.keyboardType = .numberPad
            textField.tag = 3
            textField.delegate = self
        }
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("ZipCode", comment: "ZipCode")
            textField.keyboardType = .numberPad
            textField.tag = 4
            textField.delegate = self
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .default, handler: {(action: UIAlertAction) -> Void in
            let cardNo = alertController.textFields?[0].text ?? ""
            let cvv = alertController.textFields?[1].text ?? ""
            let expiryDate = alertController.textFields?[2].text ?? ""
            let zipCode = alertController.textFields?[3].text ?? ""
            let keyedCardData = CLVModels.Payments.KeyedCardData(cardNumber: cardNo, expirationDate: expiryDate, cvv: cvv)
            keyedCardData.zipCode = zipCode
            keyedCardData.cardPresent = true
            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.processKeyedTransaction(keyedCardData: keyedCardData)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.viewController!.present(alertController, animated:true, completion:nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            if textField.tag == 1 {
                if let text = textField.text {
                    if text.count >= 16 {
                        return false
                    }
                } else {
                    return true
                }
            }
            if textField.tag == 2 {
                if let text = textField.text {
                    if text.count >= 4 {
                        return false
                    }
                } else {
                    return true
                }
            }
            if textField.tag == 3 {
                if let text = textField.text {
                    if text.count >= 4 {
                        return false
                    }
                } else {
                    return true
                }
            }
            if textField.tag == 4 {
                if let text = textField.text {
                    if text.count >= 6 {
                        return false
                    }
                } else {
                    return true
                }
            }
        }
        return true
    }
    
    override func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse: RetrievePendingPaymentsResponse) {
        OFFLINETX.retrievePendingPaymentsResponseObj = retrievePendingPaymentResponse
    }
    
    func onRetrievePendingPaymentStats(response: RetrievePendingPaymentsStatsResponse) {
        OFFLINETX.retrievePendingPaymentsStatsObj = response
        
        let name = Notification.Name(rawValue: offlineNotificationKey)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.offlineProcessingStarted), name: CloverGoConnector.OfflinePaymentProcessingStarted.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.offlineProcessingCompleted), name: CloverGoConnector.OfflinePaymentProcessingCompleted.name, object: nil)
    }
    
    @objc private func offlineProcessingStarted() {
        showMessage("Offline transaction processing started", duration: 2)
    }
    
    @objc private func offlineProcessingCompleted() {
        showMessage("Offline transaction processing completed", duration: 2)
    }
    
    override func onReadCardDataResponse(_ readCardDataResponse: ReadCardDataResponse) {
        if let vc = self.viewController as? ReadCardDataViewController {
            vc.cardDataTextView.text = ""
            if readCardDataResponse.success {
                if let goCardData = readCardDataResponse.cardData as? GoCardData {
                    if let pan = goCardData.pan {
                        vc.cardDataTextView.insertText("PAN : \(pan)\n")
                    }
                    if let cardHolderName = goCardData.cardholderName {
                        vc.cardDataTextView.insertText("Cardholder Name : \(cardHolderName)\n")
                    }
                    if let expDate = goCardData.exp {
                        vc.cardDataTextView.insertText("Exp Date : \(expDate)\n")
                    }
                    if let track1 = goCardData.track1 {
                        vc.cardDataTextView.insertText("Track 1 : \(track1)\n")
                    }
                    if let track2 = goCardData.track2 {
                        vc.cardDataTextView.insertText("Track 2 : \(track2)\n")
                    }
                    if let ksn = goCardData.ksn {
                        vc.cardDataTextView.insertText("KSN : \(ksn)\n")
                    }
                    if let encryptedTrack = goCardData.encryptedTrack {
                        vc.cardDataTextView.insertText("Encrypted Track : \(encryptedTrack)\n")
                    }
                    if let tlvData = goCardData.emvtlvData {
                        vc.cardDataTextView.insertText("TLV Data : \(tlvData)\n")
                    }
                    if let cardType = goCardData.cardType {
                        vc.cardDataTextView.insertText("Card Type : \(cardType)\n")
                    }
                }
            } else {
                if let message = readCardDataResponse.message {
                    vc.cardDataTextView.insertText("Error : \(message)\n")
                }
            }
        }
    }
    
    func onDeviceInitializationEvent(event: CLVModels.Device.GoDeviceInitializationEvent) {
        if event == .INITIALIZATION_COMPLETE || event == .FIRMWARE_UPDATE_COMPLETE {
            showMessage(event.getDescription(), duration: 1)
        } else {
            showMessage(event.getDescription(), duration: 1000)
        }
    }
    
    override func onDeviceDisconnected() {
        super.onDeviceDisconnected()
        FLAGS.is350ReaderInitialized = false
        FLAGS.is450ReaderInitialized = false
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "readerSetUpViewControllerID") as! ReaderSetUpViewController
        if let ac = self.viewController?.presentedViewController as? UIAlertController {
            ac.dismiss(animated: false, completion: {
                self.viewController?.present(nextViewController, animated:true, completion:nil)
            })
        } else {
            self.viewController?.present(nextViewController, animated:true, completion:nil)
        }
    }
    
}

