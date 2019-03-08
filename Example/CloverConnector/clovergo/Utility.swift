//
//  Utility.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import GoConnector


protocol SignatureViewDelegate {
    func isSignaturePresent(valid: Bool)
}

protocol StartTransactionDelegate{
    func proceedAfterReaderReady(merchantInfo: MerchantInfo)
    func readerDisconnected()
}

struct PARAMETERS {
    static var accessToken: String?
    static var apiKey: String?
    static var secret: String?
}

struct FLAGS {
    static var isCloverGoMode = false
    static var is350ReaderInitialized = false
    static var is450ReaderInitialized = false
}

struct SHARED {
    static let workingQueue = DispatchQueue.init(label: "my_queue")
    static var delegateStartTransaction:StartTransactionDelegate? = nil
}

struct OFFLINETX {
    static var retrievePendingPaymentsResponseObj: RetrievePendingPaymentsResponse? = nil
    static var retrievePendingPaymentsStatsObj: RetrievePendingPaymentsStatsResponse? = nil
}
