//
//  CloverGoConnectorListener.swift
//  CloverGoConnector
//
//  Created by Veeramani, Rajan (Non-Employee) on 4/17/17.
//  Copyright © 2017 Veeramani, Rajan (Non-Employee). All rights reserved.
//

import Foundation
import clovergoclient

public protocol ICloverGoConnectorListener : ICloverConnectorListener {
    
    
    func onAidMatch(cardApplicationIdentifiers:[CLVModels.Payments.CardApplicationIdentifier]) -> Void
    
    func onDevicesDiscovered(devices:[CLVModels.Device.GoDeviceInfo]) ->Void
    
    func onDeviceInitializationEvent(event:CLVModels.Device.GoDeviceInitializationEvent) -> Void
    
    func onTransactionProgress(event: CLVModels.Payments.GoTransactionEvent) -> Void
    
    func onSignatureRequired() -> Void
    
    func onSendReceipt() -> Void
    
    func onMultiplePaymentModesAvailable(paymentModes:[CLVModels.Payments.PaymentMode]) -> Void
    
    func onKeyedCardDataRequired() -> Void
    
    func onRetrievePendingPaymentStats(response : RetrievePendingPaymentsStatsResponse) -> Void
}
