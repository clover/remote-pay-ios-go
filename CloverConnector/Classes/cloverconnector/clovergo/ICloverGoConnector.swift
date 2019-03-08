//
//  ICloverGoConnector.swift
//  Pods
//
//  Created by Veeramani, Rajan (Non-Employee) on 5/2/17.
//
//

import Foundation

/// This is the Interface for CloverGo SDK
///
/// It has the interface methods required to interact with the CloverGo Reader SDK
public protocol ICloverGoConnector : ICloverConnector {
    
    /// This delegate method is used to connected with the bluetooth after the scan for devices is finished
    ///
    /// - Parameter deviceInfo: GoDeviceInfo object contains all the details about the device
    func connectToBluetoothDevice(deviceInfo:CLVModels.Device.GoDeviceInfo) -> Void
    
    /// This delegate method is called to release a connected device
    ///
    func disconnectDevice() -> Void
    
    /// This delegate method is used to add a ICloverGoConnectorListener
    ///
    /// - Parameter cloverConnectorListener: ICloverGoConnectorListener object
    func addCloverGoConnectorListener(cloverConnectorListener: ICloverGoConnectorListener) -> Void
    
    /// This delegate method is used to select an Aid to proceed with in case of multiple Aid
    ///
    /// - Parameter cardApplicationIdentier: Object of CardApplicationIdentifier containing the Aid
    func selectCardApplicationIdentifier(cardApplicationIdentier: CLVModels.Payments.CardApplicationIdentifier) -> Void
    
    /// This delegate method is used to capture the signature after a payment is made
    ///
    /// - Parameters:
    ///   - payment: Object of Payment containing the payment details
    ///   - signature: Object of Signature
    func captureSignature(signature: Signature)
    
    /// This method is called for sending the payment receipt after a successful transaction is done
    ///
    /// - Parameters:
    ///   - payment: Object of Payment containing the payment details
    ///   - email: email id to which the receipt is sent
    ///   - phone: phone no to which the receipt is sent
    func sendReceipt(email:String?, phone:String?)
    
    func selectPaymentMode(paymentMode:CLVModels.Payments.PaymentMode)
    
    func processKeyedTransaction(keyedCardData : CLVModels.Payments.KeyedCardData)
    
    func retrievePendingPaymentStats() -> Void
    
    func reRunFailedOfflineTransactions() -> Void
    
    func updateFirmware(deviceInfo:CLVModels.Device.GoDeviceInfo) -> Void
    
}
