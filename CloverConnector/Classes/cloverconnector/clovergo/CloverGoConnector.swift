//
//  CloverGoConnector.swift
//  CloverGoConnector
//
//  Created by Veeramani, Rajan (Non-Employee) on 4/17/17.
//  Copyright © 2017 Veeramani, Rajan (Non-Employee). All rights reserved.
//

import Foundation
import clovergoclient
import CloverGoReaderSDK

public class CloverGoConnector : NSObject, ICloverGoConnector, CardReaderDelegate {

    public var CARD_ENTRY_METHOD_MAG_STRIPE: Int = 0
    
    public var CARD_ENTRY_METHOD_ICC_CONTACT: Int = 1
    
    public var CARD_ENTRY_METHOD_NFC_CONTACTLESS: Int = 2
    
    public var CARD_ENTRY_METHOD_MANUAL: Int = 3
    
    public var CARD_ENTRY_METHODS_DEFAULT: Int = 4
    
    public var MAX_PAYLOAD_SIZE: Int = 5
    
    var config:CloverGoDeviceConfiguration!
    
    let cloverGo = CloverGo.sharedInstance
    
    weak var connectorListener :ICloverGoConnectorListener?
    
    var transactionDelegate : TransactionDelegate?
    
    var merchantInfo:MerchantInfo?
    
    var deviceReady = false
    
    var lastTransactionRequest : NSObject?
    
    var selectedPaymentMode : CLVModels.Payments.PaymentMode?
    
    public static let OfflinePaymentProcessingStarted : Notification = Notification.init(name: Notification.Name(rawValue:"OfflinePaymentProcessingStarted"))
    
    public static let OfflinePaymentProcessingCompleted : Notification = Notification.init(name: Notification.Name(rawValue:"OfflinePaymentProcessingCompleted"))
    
    public static let OfflinePaymentProcessingSuspended : Notification = Notification.init(name: Notification.Name(rawValue:"OfflinePaymentProcessingSuspended"))
    
    public init(config:CloverGoDeviceConfiguration) {
        super.init()
        self.config = config
        
        var env : Env
        switch config.env {
        case .demo:
            env = Env.demo
        case .live:
            env = Env.live
        case .test:
            env = Env.test
        case .sandbox:
            env = Env.sandbox
        }
        if !config.accessToken.isEmpty {
            cloverGo.initializeWithAccessToken(accessToken: config.accessToken, apiKey: config.apiKey, secret: config.secret, env: env)
        } else {
            cloverGo.initializeWithApiKey(apiKey: config.apiKey, secret: config.secret, env: env)
        }
        CloverGo.allowAutoConnect = config.allowAutoConnect
        CloverGo.overrideDuplicateTransaction = config.allowDuplicateTransaction
        CloverGo.enableLogs(config.enableLogs)
        CloverGo.enableQuickChip = config.enableQuickChip
        
        self.addNotificationObservers()
        
        self.getMerchantInfo()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.offlineProcessingStarted), name: CloverGo.OfflinePaymentProcessingStarted.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.offlineProcessingCompleted), name: CloverGo.OfflinePaymentProcessingCompleted.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.offlineProcessingSuspended), name: CloverGo.OfflinePaymentProcessingSuspended.name, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func offlineProcessingStarted() {
        NotificationCenter.default.post(name: CloverGoConnector.OfflinePaymentProcessingStarted.name, object: self, userInfo: [:])
    }
    
    @objc private func offlineProcessingCompleted() {
        NotificationCenter.default.post(name: CloverGoConnector.OfflinePaymentProcessingCompleted.name, object: self, userInfo: [:])
    }
    
    @objc private func offlineProcessingSuspended() {
        NotificationCenter.default.post(name: CloverGoConnector.OfflinePaymentProcessingSuspended.name, object: self, userInfo: [:])
    }
    
    /// This delegate method is for getting the merchant information
    ///
    private func getMerchantInfo() {
        cloverGo.getMerchantInfo(success: { (merchant) in
            self.merchantInfo = MerchantInfo(id: merchant.id, mid: nil, name: merchant.name, deviceName: nil, deviceSerialNumber: nil, deviceModel: nil)
            self.merchantInfo!.supportsAuths = (merchant.features?.contains(MerchantPropertyType.supportsAuths.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsVaultCards = (merchant.features?.contains(MerchantPropertyType.supportsVaultCards.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsManualRefunds = (merchant.features?.contains(MerchantPropertyType.supportsManualRefunds.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsTipAdjust = (merchant.features?.contains(MerchantPropertyType.supportsTipAdjust.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsPreAuths = (merchant.features?.contains(MerchantPropertyType.supportsPreAuths.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsVoids = (merchant.features?.contains(MerchantPropertyType.supportsVoids.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsSales = (merchant.features?.contains(MerchantPropertyType.supportsSales.toString()) ?? true) ? true : false
            
        }) { (error) in
            //Not expecting an error for now
        }
    }
    
    /// This delegate method is called to connect to a device
    ///
    public func initializeConnection() {
        let readerInfo = ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil)
        cloverGo.useReader(cardReaderInfo: readerInfo, delegate: self)
    }
    
    
    /// This delegate method is used to connected with the bluetooth after the scan for devices is finished
    ///
    /// - Parameter deviceInfo: GoDeviceInfo object contains all the details about the device
    public func connectToBluetoothDevice(deviceInfo:CLVModels.Device.GoDeviceInfo) {
        let reader = ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: deviceInfo.type), serialNumber: nil)
        reader.bluetoothId = deviceInfo.bluetoothId
        reader.bluetoothName = deviceInfo.deviceName
        cloverGo.connectToBTReader(readerInfo: reader)
    }
    
    /// This delegate method is called to release a connected device
    ///
    public func disconnectDevice() {
        let readerInfo = ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil)
        cloverGo.releaseReader(cardReaderInfo: readerInfo)
    }
    
    /// This delegate method is called to reset a reader
    ///
    public func resetDevice() {
        cloverGo.resetReader(readerInfo: ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil))
    }
    
    public func cancel() {
        cloverGo.cancelCardReaderTransaction(readerInfo: ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil))
    }
    
    /// This delegate method is used to add a ICloverConnectorListener
    ///
    /// - Parameter cloverConnectorListener: ICloverConnectorListener object
    public func addCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void {
        //Not to be implemented
    }
    
    /// This delegate method is used to remove a ICloverConnectorListener
    ///
    /// - Parameter cloverConnectorListener: ICloverConnectorListener object
    public func removeCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void {
        //Not to be implemented
    }
    
    /// This delegate method is used to add a ICloverGoConnectorListener
    ///
    /// - Parameter cloverConnectorListener: ICloverGoConnectorListener object
    public func addCloverGoConnectorListener(cloverConnectorListener: ICloverGoConnectorListener) {
        connectorListener = cloverConnectorListener
    }
    
    /// This delegate method is used to do a sale transaction
    ///
    /// - Parameter saleRequest: Construct SaleRequest object with required fields
    public func sale(_ saleRequest: SaleRequest) {
        resetState()
        if merchantInfo?.supportsSales != nil && !(merchantInfo?.supportsSales)! {
            connectorListener?.onSaleResponse(SaleResponse(success: false, result: ResultCode.UNSUPPORTED))
        } else {
            executeTransaction(transactionRequest: saleRequest)
        }
    }
    
    /// This delegate method is used to do a auth transaction
    ///
    /// - Parameter authRequest: Construct AuthRequest object with required fields
    public func auth(_ authRequest: AuthRequest) {
        resetState()
        if merchantInfo?.supportsAuths != nil && !(merchantInfo?.supportsAuths)! {
            connectorListener?.onAuthResponse(AuthResponse(success: false, result: ResultCode.UNSUPPORTED))
        } else {
            executeTransaction(transactionRequest: authRequest)
        }
    }
    
    /// This delegate method is used to do a preAuth transaction
    ///
    /// - Parameter preAuthRequest: Construct PreAuthRequest object with required fields
    public func preAuth(_ preAuthRequest: PreAuthRequest) {
        resetState()
        if merchantInfo?.supportsPreAuths != nil && !(merchantInfo?.supportsPreAuths)! {
            connectorListener?.onPreAuthResponse(PreAuthResponse(success: false, result: ResultCode.UNSUPPORTED))
        } else {
            executeTransaction(transactionRequest: preAuthRequest)
        }
    }
    
    /// This delegate method is used to perform a transaction
    ///
    /// - Parameters:
    ///   - transactionRequest: Object of TransactionRequest containing the request details
    ///   - delegate: Object of TransactionDelegate containing the transaction delegate methods
    private func executeTransaction(transactionRequest:NSObject) {
        lastTransactionRequest = transactionRequest
        if transactionRequest is SaleRequest {
            transactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .purchase)
        } else if transactionRequest is AuthRequest {
            transactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .auth)
        } else if transactionRequest is PreAuthRequest {
            transactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .preauth)
        } else if transactionRequest is ManualRefundRequest {
            transactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .manualrefund)
        } else if transactionRequest is VaultCardRequest {
            transactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .tokenize)
        }
        
        let paymentModes = self.getAvailablePaymentModes()
        if paymentModes.count > 1 {
            connectorListener?.onMultiplePaymentModesAvailable(paymentModes: paymentModes)
        } else {
            self.selectedPaymentMode = .KEYED_TRANSACTION
            connectorListener?.onKeyedCardDataRequired()
        }
    }
    
    public func selectPaymentMode(paymentMode: CLVModels.Payments.PaymentMode) {
        self.selectedPaymentMode = paymentMode
        switch paymentMode {
        case .READER_TRANSACTION:
            if let order = getOrder(), let delegate = transactionDelegate {
                let readerType = EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType)
                cloverGo.doCardReaderTransaction(readerInfo: ReaderInfo(readerType: readerType, serialNumber: nil), order: order, delegate: delegate)
            } else {
                sendErrorResponse(reason: "transaction_failed", message: "Could not process the transaction, Please try again")
            }
        case .KEYED_TRANSACTION:
            connectorListener?.onKeyedCardDataRequired()
        }
    }
    
    private func getOrder() -> Order? {
        var order:Order?
        if let transactionRequest = lastTransactionRequest {
            order = Order()
            order!.note = (transactionRequest as? TransactionRequest)?.paymentNote
            if let saleRequest = transactionRequest as? SaleRequest {
                order!.tax = saleRequest.taxAmount ?? 0
                order!.tip = saleRequest.tipAmount ?? 0
                order!.addCustomItem(item: CustomItem(name: "Item 1", price: saleRequest.amount - order!.tax, quantity: 1))
                order!.transactionType = .purchase
            } else if let authRequest = transactionRequest as? AuthRequest {
                order!.tax = authRequest.taxAmount ?? 0
                order!.addCustomItem(item: CustomItem(name: "Item 1", price: authRequest.amount - order!.tax, quantity: 1))
                order!.tip = -1
                order!.transactionType = .auth
            } else if let preAuthRequest = transactionRequest as? PreAuthRequest {
                order!.addCustomItem(item: CustomItem(name: "Item 1", price: preAuthRequest.amount, quantity: 1))
                order!.transactionType = .preauth
                order!.tax = -1
                order!.tip = -1
            } else if let manualReundRequest = transactionRequest as? ManualRefundRequest {
                order!.addCustomItem(item: CustomItem(name: "Item 1", price: manualReundRequest.amount, quantity: 1))
                order!.transactionType = .manualrefund
                order!.tax = -1
                order!.tip = -1
            } else if transactionRequest is VaultCardRequest {
                order!.addCustomItem(item: CustomItem(name: "Item 1", price: 1, quantity: 1))
                order!.transactionType = .tokenize
                order!.tax = -1
                order!.tip = -1
            }
            if let transactionRequest = transactionRequest as? TransactionRequest {
                order!.externalPaymentId = transactionRequest.externalId
            }
        }
        return order
    }
    
    public func processKeyedTransaction(keyedCardData: CLVModels.Payments.KeyedCardData) {
        if let order = getOrder(), let delegate = transactionDelegate {
            let keyedRequest = KeyedRequest(cardNumber: keyedCardData.cardNumber, expDate: keyedCardData.expirationDate, cvv: keyedCardData.cvv, order: order, zipCode: keyedCardData.zipCode, streetAddress: keyedCardData.address, cardPresent: keyedCardData.cardPresent)
            if self.deviceReady {
                keyedRequest.readerConnected = true
            }
            cloverGo.doKeyedTransaction(keyedRequest: keyedRequest, delegate: delegate)
        } else {
            sendErrorResponse(reason: "transaction_failed", message: "Could not process the transaction, Please try again")
        }
    }
    
    private func sendErrorResponse(reason:String, message:String) {
        if let transactionRequest = lastTransactionRequest {
            if transactionRequest is SaleRequest {
                let saleResponse = SaleResponse(success: false, result: .ERROR)
                saleResponse.reason = reason
                saleResponse.message = message
                connectorListener?.onSaleResponse(saleResponse)
            } else if transactionRequest is AuthRequest {
                let authResponse = AuthResponse(success: false, result: .ERROR)
                authResponse.reason = reason
                authResponse.message = message
                connectorListener?.onAuthResponse(authResponse)
            } else if transactionRequest is PreAuthRequest {
                let preAuthResponse = PreAuthResponse(success: false, result: .ERROR)
                preAuthResponse.reason = reason
                preAuthResponse.message = message
                connectorListener?.onPreAuthResponse(preAuthResponse)
            } else if transactionRequest is ManualRefundRequest {
                let manualRefundResponse = ManualRefundResponse(success: false, result: .ERROR)
                manualRefundResponse.reason = reason
                manualRefundResponse.message = message
                connectorListener?.onManualRefundResponse(manualRefundResponse)
            } else if transactionRequest is VaultCardRequest {
                let vaultCardResponse = VaultCardResponse(success: false, result: .ERROR)
                vaultCardResponse.reason = reason
                vaultCardResponse.message = message
                connectorListener?.onVaultCardResponse(vaultCardResponse)
            }
        }
    }
    
    private func getAvailablePaymentModes() -> [CLVModels.Payments.PaymentMode] {
        var paymentModes = [CLVModels.Payments.PaymentMode]()
        paymentModes.append(.KEYED_TRANSACTION)
        if self.deviceReady {
            paymentModes.append(.READER_TRANSACTION)
        }
        return paymentModes
    }
    
    /// This delegate method is used to do a tipAdjustAuth
    ///
    /// - Parameter authTipAdjustRequest: Construct TipAdjustAuthRequest object with required fields
    public func tipAdjustAuth(_ authTipAdjustRequest: TipAdjustAuthRequest) {
        
        if merchantInfo?.supportsTipAdjust != nil && !(merchantInfo?.supportsTipAdjust)! {
            
            connectorListener?.onTipAdjustAuthResponse(TipAdjustAuthResponse(success: false, result: ResultCode.UNSUPPORTED,paymentId: authTipAdjustRequest.paymentId, tipAmount: authTipAdjustRequest.tipAmount))
            
        } else {
            cloverGo.doAddTipTransaction(paymentId: authTipAdjustRequest.paymentId, amount: authTipAdjustRequest.tipAmount, success: { (result) in
                self.connectorListener?.onTipAdjustAuthResponse(TipAdjustAuthResponse(success: true, result: ResultCode.SUCCESS,paymentId: authTipAdjustRequest.paymentId, tipAmount: authTipAdjustRequest.tipAmount))
            }) { (error) in
                let tipAdjustResponse = TipAdjustAuthResponse(success: false, result: ResultCode.FAIL,paymentId: authTipAdjustRequest.paymentId, tipAmount: authTipAdjustRequest.tipAmount)
                tipAdjustResponse.reason = error.code
                tipAdjustResponse.message = error.message
                self.connectorListener?.onTipAdjustAuthResponse(tipAdjustResponse)
            }
        }
    }
    
    /// This delegate method is used to do a capture a PreAuth transaction
    ///
    /// - Parameter capturePreAuthRequest: Construct CapturePreAuthRequest object with required fields
    public func capturePreAuth(_ capturePreAuthRequest: CapturePreAuthRequest) {
        cloverGo.doCapturePreAuthTransaction(paymentId: capturePreAuthRequest.paymentId, amount: capturePreAuthRequest.amount, tipAmount: capturePreAuthRequest.tipAmount ?? 0, success: { (result) in
            self.connectorListener?.onCapturePreAuthResponse(CapturePreAuthResponse(success: true, result: ResultCode.SUCCESS, paymentId: capturePreAuthRequest.paymentId, amount: capturePreAuthRequest.amount, tipAmount: capturePreAuthRequest.tipAmount))
        }) { (error) in
            let capturePreAuthResponse = CapturePreAuthResponse(success: false, result: ResultCode.FAIL, paymentId: capturePreAuthRequest.paymentId, amount: capturePreAuthRequest.amount, tipAmount: capturePreAuthRequest.tipAmount)
            capturePreAuthResponse.reason = error.code
            capturePreAuthResponse.message = error.message
            self.connectorListener?.onCapturePreAuthResponse(capturePreAuthResponse)
        }
    }
    
    /// This delegate method is used to Void a payment
    ///
    /// - Parameter voidPaymentRequest: Construct VoidPaymentRequest object with required fields
    public func voidPayment(_ voidPaymentRequest: VoidPaymentRequest) {
        if merchantInfo?.supportsVoids != nil && !(merchantInfo?.supportsVoids)! {
            connectorListener?.onVoidPaymentResponse(VoidPaymentResponse(success: false, result: ResultCode.UNSUPPORTED, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil))
        } else {
            guard voidPaymentRequest.paymentId != nil && voidPaymentRequest.orderId != nil else {
                let voidErrorResponse = VoidPaymentResponse(success: false, result: ResultCode.FAIL, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil)
                voidErrorResponse.reason = "invalid_request"
                voidErrorResponse.message = "Order Id and Payment Id in the request cannot be nil"
                connectorListener?.onVoidPaymentResponse(voidErrorResponse)
                return
            }
            cloverGo.doVoidTransaction(paymentId: voidPaymentRequest.paymentId!, orderId: voidPaymentRequest.orderId!, voidReason: EnumerationUtil.VoidReason_toString(type: voidPaymentRequest.voidReason),success: { (result) in
                self.connectorListener?.onVoidPaymentResponse(VoidPaymentResponse(success: true, result: ResultCode.SUCCESS, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil))
            }) { (error) in
                let voidResponse = VoidPaymentResponse(success: false, result: ResultCode.FAIL, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil)
                voidResponse.reason = error.code
                voidResponse.message = error.message
                self.connectorListener?.onVoidPaymentResponse(voidResponse)
            }
        }
        
    }
    
    /// This delegate method is used to Refund a payment
    ///
    /// - Parameter refundPaymentRequest: Construct RefundPaymentRequest object with required fields
    public func refundPayment(_ refundPaymentRequest: RefundPaymentRequest) {
        cloverGo.doRefundTransactionWithAmount(paymentId: refundPaymentRequest.paymentId, amount: refundPaymentRequest.amount ?? 0, success: { (response) in
            let refund = CLVModels.Payments.Refund()
            refund.id = response.id
            refund.amount = response.amount
            refund.payment = CLVModels.Payments.Payment()
            refund.payment?.id = response.paymentId
            self.connectorListener?.onRefundPaymentResponse(RefundPaymentResponse(success: true, result: ResultCode.SUCCESS, orderId: refundPaymentRequest.orderId, paymentId: refundPaymentRequest.paymentId, refund: refund))
        }) { (error) in
            let refundResponse = RefundPaymentResponse(success: false, result: ResultCode.FAIL)
            refundResponse.reason = error.code
            refundResponse.message = error.message
            self.connectorListener?.onRefundPaymentResponse(refundResponse)
        }
    }
    
    /// This delegate method is used to perform a closeout
    ///
    /// - Parameter closeoutRequest: Construct CloseoutRequest object with required fields
    public func closeout(_ closeoutRequest: CloseoutRequest) {
        cloverGo.doCloseOutTransaction(success: { (status) in
            self.connectorListener?.onCloseoutResponse(CloseoutResponse(batch: nil, success: true, result: ResultCode.SUCCESS))
        }) { (error) in
            let closeOutResponse = CloseoutResponse(batch: nil, success: false, result: ResultCode.FAIL)
            closeOutResponse.reason = error.code
            closeOutResponse.message = error.message
            self.connectorListener?.onCloseoutResponse(closeOutResponse)
        }
    }
    
    /// This delegate method is called when the card reader is detected and selected from the readers list
    ///
    /// - Parameter readers: List of connected readers
    public func onCardReaderDiscovered(readers: [ReaderInfo]) {
        var discoveredReaders : [CLVModels.Device.GoDeviceInfo] = []
        for r in readers {
            let reader = CLVModels.Device.GoDeviceInfo(name: r.bluetoothName ?? r.readerName, serial: "", model: "")
            reader.type = EnumerationUtil.CardReaderType_toGoReaderType(type: r.readerType)
            reader.bluetoothId = r.bluetoothId
            discoveredReaders.append(reader)
        }
        connectorListener?.onDevicesDiscovered(devices: discoveredReaders)
    }
    
    /// This delegate method is called after the card reader is connected
    ///
    /// - Parameter cardReaderInfo: ReaderInfo object contains all the details about the reader
    public func onConnected(cardReaderInfo: ReaderInfo) {
        connectorListener?.onDeviceConnected()
    }
    
    /// This delegate method is called after the card reader is disconnected from the app
    ///
    /// - Parameter cardReaderInfo: ReaderInfo object contains all the details about the reader
    public func onDisconnected(cardReaderInfo: ReaderInfo) {
        self.deviceReady = false
        connectorListener?.onDeviceDisconnected()
    }
    
    /// This delegate method is called if we get any error with the card reader
    ///
    /// - Parameter event: Gives the details about the event which caused the reader error
    public func onError(event: CardReaderErrorEvent) {
        debugPrint("Error Occured while connecting to Reader")
        connectorListener?.onDeviceError(CloverDeviceErrorEvent(errorType: .EXCEPTION, code: 500, cause: nil, message: event.toString()))
    }
    
    /// This delegate method is called when the card reader is undergoing a reader reset
    ///
    /// - Parameter event: Gives the details about the CardReaderEvent during reader reset process
    public func onReaderResetProgress(event: CardReaderInitializationEvent) {
        connectorListener?.onDeviceInitializationEvent(event: EnumerationUtil.CardReaderInitializationEvent_toGoDeviceInitializationEvent(event: event))
    }
    
    /// This delegate method is called when the reader is ready to start a new transaction. Start transaction should be called after this method.
    ///
    /// - Parameter cardReaderInfo: ReaderInfo object contains details about the connected reader
    public func onReady(cardReaderInfo: ReaderInfo) {
        debugPrint("Reader is Ready!")
        deviceReady = true
        let currMerchantInfo = MerchantInfo()
        currMerchantInfo.merchantId = self.merchantInfo?.merchantId
        currMerchantInfo.merchantName = self.merchantInfo?.merchantName
        let deviceInfo = CLVModels.Device.GoDeviceInfo(name: cardReaderInfo.bluetoothName ?? cardReaderInfo.readerName, serial: cardReaderInfo.serialNumber, model: cardReaderInfo.readerType.toString())
        deviceInfo.batteryPercentage = cardReaderInfo.batteryPercentage
        deviceInfo.firmwareVersion = cardReaderInfo.firmwareVersion
        deviceInfo.connected = true
        currMerchantInfo.deviceInfo = deviceInfo
        if let mercInfo = self.merchantInfo {
            currMerchantInfo.supportsAuths = mercInfo.supportsAuths
            currMerchantInfo.supportsVaultCards = mercInfo.supportsVaultCards
            currMerchantInfo.supportsManualRefunds = mercInfo.supportsManualRefunds
            currMerchantInfo.supportsTipAdjust = mercInfo.supportsTipAdjust
            currMerchantInfo.supportsPreAuths = mercInfo.supportsPreAuths
            currMerchantInfo.supportsVoids = mercInfo.supportsVoids
            currMerchantInfo.supportsSales = mercInfo.supportsSales
        } else {
            getMerchantInfo()
            debugPrint("Could not retrieve Merchant properties")
        }
        self.connectorListener?.onDeviceReady(currMerchantInfo)
    }
    
    
    //TODO: Throw exceptions instead of logs
    /*
     * Request receipt options be displayed for a payment.
     */
    public func displayPaymentReceiptOptions( orderId:String, paymentId: String) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Accept a signature verification request.
     */
    public func  acceptSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Reject a signature verification request.
     */
    public func  rejectSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to vault a card.
     */
    public func  vaultCard ( _ vaultCardRequest:VaultCardRequest ) -> Void {
        resetState()
        if merchantInfo?.supportsVaultCards != nil && !(merchantInfo?.supportsVaultCards)! {
            connectorListener?.onVaultCardResponse(VaultCardResponse(success: false, result: ResultCode.UNSUPPORTED))
        } else {
            executeTransaction(transactionRequest: vaultCardRequest)
        }
    }
    
    
    /*
     * Request to print some text on the default printer.
     */
    public func  printText ( _ lines:[String] ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func printImageFromURL(_ url:String) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request that the cash drawer connected to the device be opened.
     */
    public func  openCashDrawer (reason: String) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to place a message on the device screen.
     */
    public func  showMessage ( _ message:String ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display the default welcome screen on the device.
     */
    public func  showWelcomeScreen () -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display the default thank you screen on the device.
     */
    public func  showThankYouScreen () -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display an order on the device.
     */
    public func  showDisplayOrder ( _ order:DisplayOrder ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display an order on the device.
     */
    public func  removeDisplayOrder ( _ order:DisplayOrder ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func invokeInputOption( _ inputOption:InputOption ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func readCardData( _ request:ReadCardDataRequest ) -> Void {
        if self.deviceReady {
            self.transactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: nil)
            let readerType = EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType)
            cloverGo.doReadCardData(readerInfo: ReaderInfo(readerType: readerType, serialNumber: nil), delegate: self.transactionDelegate!)
        } else {
            let response = ReadCardDataResponse(success: false, result: .FAIL)
            response.reason = "reader_not_ready"
            response.message = "Reader not ready"
            self.connectorListener?.onReadCardDataResponse(response)
        }
    }
    
    public func print(_ request: PrintRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrievePrinters(_ request: RetrievePrintersRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrievePrintJobStatus(_ request: PrintJobStatusRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func openCashDrawer(_ request: OpenCashDrawerRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func acceptPayment( _ payment:CLVModels.Payments.Payment ) -> Void {
        if transactionDelegate != nil {
            (transactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: true)
        }
    }
    
    public func rejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge ) -> Void {
        if transactionDelegate != nil {
            (transactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: false)
        }
    }
    
    public func retrievePendingPayments() -> Void {
        cloverGo.getOfflineTransactionHistory { (transactions) in
            if let transactions = transactions {
                var pendingPayments = [GoPendingPaymentEntry]()
                for txn in transactions {
                    let pendingPayment = GoPendingPaymentEntry()
                    pendingPayment.createdTime = txn.createdTime
                    pendingPayment.failureReason = txn.failureReason
                    pendingPayment.orderId = txn.orderId
                    pendingPayment.state = EnumerationUtil.TransactionState_toGoPendingPaymentState(state: txn.offlineState)
                    pendingPayment.paymentId = txn.paymentId
                    pendingPayment.amount = txn.amount
                    pendingPayments.append(pendingPayment)
                }
               let response = RetrievePendingPaymentsResponse(code: .SUCCESS, message: "Success", payments: pendingPayments)
                self.connectorListener?.onRetrievePendingPaymentsResponse(response)
                
            } else {
                let response = RetrievePendingPaymentsResponse(code: .FAIL, message: "No Pending Payments Found", payments: nil)
                self.connectorListener?.onRetrievePendingPaymentsResponse(response)
            }
        }
        
    }
    
    public func retrievePendingPaymentStats() -> Void {
        cloverGo.getOfflineStats { (offlineStats) in
            let response = RetrievePendingPaymentsStatsResponse(code: .SUCCESS, message: "Pending Payment Stats retrieved")
            response.totalPaymentAmount = offlineStats.totalAmount
            response.totalPaymentCount = offlineStats.totalTransactionCount
            response.failedPaymentCount = offlineStats.failedTransactionCount
            response.pendingPaymentCount = offlineStats.pendingTransactionCount
            response.noOfDaysOffline = offlineStats.noOfDaysOffline
            self.connectorListener?.onRetrievePendingPaymentStats(response: response)
        }
    }
    
    public func dispose() -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func startCustomActivity(_ request:CustomActivityRequest) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    /*
     * Request an amount be refunded.
     */
    public func  manualRefund ( _ manualRefundRequest:ManualRefundRequest ) -> Void{
        resetState()
        if merchantInfo?.supportsManualRefunds != nil && !(merchantInfo?.supportsManualRefunds)! {
            connectorListener?.onManualRefundResponse(ManualRefundResponse(success: false, result: ResultCode.UNSUPPORTED))
        } else {
            executeTransaction(transactionRequest: manualRefundRequest)
        }
    }
    
    /// This delegate method is used to select an Aid to proceed with in case of multiple Aid
    ///
    /// - Parameter cardApplicationIdentier: Object of CardApplicationIdentifier containing the Aid
    public func selectCardApplicationIdentifier(cardApplicationIdentier: CLVModels.Payments.CardApplicationIdentifier) {
        if let delegate = transactionDelegate as? TransactionDelegateImpl {
            delegate.proceedWithSelectedAid(cardApplicationIdentifier: cardApplicationIdentier)
        }
    }
    
    private func resetState() {
        self.transactionDelegate = nil
        self.lastTransactionRequest = nil
    }
    
    /// This delegate method is used to capture the signature after a payment is made
    ///
    /// - Parameters:
    ///   - payment: Object of Payment containing the payment details
    ///   - signature: Object of Signature
    public func captureSignature(payment: CLVModels.Payments.Payment, signature: Signature) {
        if let paymentId = payment.id {
            var strokesArray :Array<[[Int]]> = []
            if let strokes = signature.strokes {
                for stroke in strokes {
                    if let points = stroke.points {
                        var pointsArray:[[Int]] = []
                        for point in points {
                            if let x = point.x, let y = point.y {
                                pointsArray.append([x,y])
                            }
                        }
                        strokesArray.append(pointsArray)
                    }
                }
            }
            cloverGo.captureSignature(paymentId: paymentId, xy: strokesArray)
        }
    }
    
    public func captureSignature(signature: Signature) {
        var strokesArray :Array<[[Int]]> = []
        if let strokes = signature.strokes {
            for stroke in strokes {
                if let points = stroke.points {
                    var pointsArray:[[Int]] = []
                    for point in points {
                        if let x = point.x, let y = point.y {
                            pointsArray.append([x,y])
                        }
                    }
                    strokesArray.append(pointsArray)
                }
            }
        }
        
        let delegate : TransactionDelegateImpl? = transactionDelegate as? TransactionDelegateImpl
        
        if let paymentId = delegate?.lastTransactionResult?.paymentId {
            cloverGo.captureSignature(paymentId: paymentId, xy: strokesArray)
            connectorListener?.onSendReceipt()
        }
        
    }
    
    /// This method is called for sending the payment receipt after a successful transaction is done
    ///
    /// - Parameters:
    ///   - payment: Object of Payment containing the payment details
    ///   - email: email id to which the receipt is sent
    ///   - phone: phone no to which the receipt is sent
    public func sendReceipt(email:String?, phone:String?) {
        let delegate : TransactionDelegateImpl? = transactionDelegate as? TransactionDelegateImpl
        
        if let orderId = delegate?.lastTransactionResult?.orderId {
            cloverGo.sendReceipt(orderId: orderId, email: email, phone: phone)
            delegate?.sendTransactionResponse()
        }
    }
    
    public func reRunFailedOfflineTransactions() {
        self.cloverGo.reRunFailedOfflineTransactions()
    }
    
    public func printImage(_ image: UIImage) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrievePayment(_ _request: RetrievePaymentRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrieveDeviceStatus(_ _request: RetrieveDeviceStatusRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func sendMessageToActivity(_ request: MessageToActivity) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func updateFirmware(deviceInfo: CLVModels.Device.GoDeviceInfo) {
        let reader = ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: deviceInfo.type), serialNumber: nil)
        cloverGo.updateFirmware(cardReaderInfo: reader)
    }

}

class TransactionDelegateImpl : NSObject, TransactionDelegate {
    
    weak var connectorListener : ICloverGoConnectorListener?
    
    let transactionType : CLVGoTransactionType?
    
    var proceedOnErrorDelegate : ProceedOnError?
    var aidSelectionDelegate : AidSelection?
    var aidSelectionList : [CardApplicationIdentifier]?
    
    var lastTransactionResult : TransactionResult?
    
    init(connectorListener: ICloverGoConnectorListener?, transactionType:CLVGoTransactionType?) {
        self.connectorListener = connectorListener
        self.transactionType = transactionType
    }
    
    /// This delegate method is called when there is any event with the card reader after the transaction is started
    ///
    /// - Parameter event: Gives the details about the CardReaderEvent during the transaction
    func onProgress(event: TransactionEvent) {
        if let transactionEvent = EnumerationUtil.TransactionEvent_toGoReaderTransactionEvent(event: event) {
            self.connectorListener?.onTransactionProgress(event: transactionEvent)
        }
    }
    
    /// This delegate method is called when there is any error from the backend during a transaction
    ///
    /// - Parameter error: CloverGoError containing the error details
    func onError(error: CloverGoError) {
        if transactionType == nil {
            let response = ReadCardDataResponse(success: false, result: .FAIL)
            response.reason = error.code
            response.message = error.message
            connectorListener?.onReadCardDataResponse(response)
        } else if transactionType == CLVGoTransactionType.purchase {
            let saleResponse = SaleResponse(success: false, result: .FAIL)
            saleResponse.reason = error.code
            saleResponse.message = error.message
            connectorListener?.onSaleResponse(saleResponse)
        } else if transactionType == CLVGoTransactionType.auth {
            let authResponse = AuthResponse(success: false, result: .FAIL)
            authResponse.reason = error.code
            authResponse.message = error.message
            connectorListener?.onAuthResponse(authResponse)
        } else if transactionType == CLVGoTransactionType.preauth {
            let preAuthResponse = PreAuthResponse(success: false, result: .FAIL)
            preAuthResponse.reason = error.code
            preAuthResponse.message = error.message
            connectorListener?.onPreAuthResponse(preAuthResponse)
        } else if transactionType == CLVGoTransactionType.manualrefund {
            let manualRefundResponse = ManualRefundResponse(success: false, result: .FAIL)
            manualRefundResponse.reason = error.code
            manualRefundResponse.message = error.message
            connectorListener?.onManualRefundResponse(manualRefundResponse)
        } else if transactionType == CLVGoTransactionType.tokenize {
            let vaultCardResponse = VaultCardResponse(success: false, result: .FAIL)
            vaultCardResponse.reason = error.code
            vaultCardResponse.message = error.message
            connectorListener?.onVaultCardResponse(vaultCardResponse)
        }
    }
    
    /// This delegate method is called upon receiving a response after the transaction is done
    ///
    /// - Parameter transactionResponse: TransactionResult object containing details of the transaction
    func onTransactionResponse(transactionResponse: TransactionResult) {
        self.lastTransactionResult = transactionResponse
        let cvmResult = EnumerationUtil.CvmResult_toEnum(type: transactionResponse.cvmResult ?? "")
        if cvmResult == .SIGNATURE {
            connectorListener?.onSignatureRequired()
        } else {
            if transactionType != .tokenize {
                connectorListener?.onSendReceipt()
            } else {
                self.sendTransactionResponse()
            }
        }
        
    }
    
    func sendTransactionResponse() {
        if let transactionResponse = lastTransactionResult {
            
            let order = CLVModels.Base.Reference()
            order.id = transactionResponse.orderId
            
            let cardTransaction = CLVModels.Payments.CardTransaction()
            cardTransaction.authCode = transactionResponse.authCode
            cardTransaction.type_ = EnumerationUtil.CardTransactionType_toEnum(type: transactionResponse.transactionType ?? "")
            cardTransaction.cardType = EnumerationUtil.CardType_toEnum(type: transactionResponse.cardType ?? "")
            cardTransaction.entryType = EnumerationUtil.CardEntryType_toEnum(type: transactionResponse.mode ?? "")
            if let maskedCardNo = transactionResponse.maskedCardNo {
                cardTransaction.first6 = String(maskedCardNo.prefix(6))
                cardTransaction.last4 = String(maskedCardNo.suffix(4))
            }
            cardTransaction.cardholderName = transactionResponse.cardHolderName
            
            let payment = CLVModels.Payments.Payment()
            payment.id = transactionResponse.paymentId
            payment.amount = transactionResponse.amountCharged
            payment.taxAmount = transactionResponse.taxAmount
            payment.tipAmount = transactionResponse.tipAmount
            payment.externalPaymentId = transactionResponse.externalPaymentId
            
            payment.order = order
            payment.cardTransaction = cardTransaction
            
            if transactionType == CLVGoTransactionType.purchase {
                let response = SaleResponse(success: true, result: ResultCode.SUCCESS)
                payment.result = CLVModels.Payments.Result.SUCCESS
                response.payment = payment
                connectorListener?.onSaleResponse(response)
            } else if transactionType == CLVGoTransactionType.auth {
                let response = AuthResponse(success: true, result: ResultCode.SUCCESS)
                payment.result = CLVModels.Payments.Result.SUCCESS
                response.payment = payment
                connectorListener?.onAuthResponse(response)
            } else if transactionType == CLVGoTransactionType.preauth {
                let response = PreAuthResponse(success: true, result: ResultCode.SUCCESS)
                payment.result = CLVModels.Payments.Result.AUTH
                response.payment = payment
                connectorListener?.onPreAuthResponse(response)
            } else if transactionType == CLVGoTransactionType.manualrefund {
                let credit = CLVModels.Payments.Credit()
                credit.amount = transactionResponse.amountCharged
                credit.id = transactionResponse.paymentId
                credit.taxAmount = transactionResponse.taxAmount
                let orderRef = CLVModels.Order.Order()
                orderRef.id = transactionResponse.orderId
                credit.orderRef = orderRef
                credit.cardTransaction = cardTransaction
                let response = ManualRefundResponse(success: true, result: ResultCode.SUCCESS, credit: credit)
                connectorListener?.onManualRefundResponse(response)
            } else if transactionType == CLVGoTransactionType.tokenize {
                let vaultCardResponse = VaultCardResponse(success: true, result: .SUCCESS)
                let vaultedCard = CLVModels.Payments.VaultedCard()
                vaultedCard.cardholderName = transactionResponse.cardHolderName
                vaultedCard.expirationDate = transactionResponse.expirationDate
                if let maskedCardNo = transactionResponse.maskedCardNo {
                    vaultedCard.first6 = String(maskedCardNo.prefix(6))
                    vaultedCard.last4 = String(maskedCardNo.suffix(4))
                }
                vaultedCard.token = transactionResponse.token
                vaultCardResponse.card = vaultedCard
                connectorListener?.onVaultCardResponse(vaultCardResponse)
            }
        }
    }
    
    /// This delegate method is called on AVS failure or for duplicate transaction
    ///
    /// - Parameters:
    ///   - event: TransactionEvent object
    ///   - proceedOnErrorDelegate: ProceedOnError delegate
    func proceedOnError(event: TransactionErrorEvent, proceedOnErrorDelegate: ProceedOnError) {
        
        var challenges : [Challenge] = []
        switch event {
        case .duplicate_transaction:
            let challenge = Challenge()
            challenge.message = "Duplicate Transaction"
            challenge.type = ChallengeType.DUPLICATE_CHALLENGE
            challenges.append(challenge)
        case .partial_auth:
            let challenge = Challenge()
            challenge.message = "Transaction Partially Authorized"
            challenge.type = ChallengeType.PARTIAL_AUTH_CHALLENGE
            challenges.append(challenge)
        case .avs_failure:
            let challenge = Challenge()
            challenge.message = "AVS Verification Failed"
            challenge.type = ChallengeType.AVS_FAILURE_CHALLENGE
            challenges.append(challenge)
        case .offline:
            let challenge = Challenge()
            challenge.message = "Device is Offline"
            challenge.type = ChallengeType.OFFLINE_CHALLENGE
            challenges.append(challenge)
        case .offline_threshold_limit_exceeded:
            let challenge = Challenge()
            challenge.message = "Payment threshold limit exceeded"
            challenge.type = ChallengeType.OFFLINE_THRESHOLD_LIMIT_EXCEEDED_CHALLENGE
            challenges.append(challenge)
        case .cvv_mismatch:
            let challenge = Challenge()
            challenge.message = "CVV Mismatch"
            challenge.type = ChallengeType.CVV_MISMATCH_CHALLENGE
            challenges.append(challenge)
        
        }
        let confirmPaymentRequest = ConfirmPaymentRequest()
        confirmPaymentRequest.challenges = challenges
        
        let payment = CLVModels.Payments.Payment()
        payment.id = "Pending"
        
        confirmPaymentRequest.payment = payment
        connectorListener?.onConfirmPaymentRequest(confirmPaymentRequest)
        self.proceedOnErrorDelegate = proceedOnErrorDelegate
        
    }
    
    func onAidMatch(cardApplicationIdentifiers: [CardApplicationIdentifier], delegate: AidSelection) {
        self.aidSelectionDelegate = delegate
        self.aidSelectionList = cardApplicationIdentifiers
        var aidList : [CLVModels.Payments.CardApplicationIdentifier] = []
        for caid in cardApplicationIdentifiers {
            let aid = CLVModels.Payments.CardApplicationIdentifier(applicationLabel: caid.applicationLabel, applicationIdentifier: caid.applicationIdentifier)
            aidList.append(aid)
        }
        connectorListener?.onAidMatch(cardApplicationIdentifiers: aidList)
    }
    
    /// This delegate method is used to proceed with a transaction after selecting an Aid
    ///
    /// - Parameter cardApplicationIdentifier: Object of CardApplicationIdentifier containing the Aid 
    func proceedWithSelectedAid(cardApplicationIdentifier:CLVModels.Payments.CardApplicationIdentifier) {
        if (aidSelectionList != nil) {
            for aid in self.aidSelectionList! {
                if aid.applicationIdentifier == cardApplicationIdentifier.applicationIdentifier && aid.applicationLabel == cardApplicationIdentifier.applicationLabel {
                    self.aidSelectionDelegate?.selectApplicationIdentifier(cardApplicationIdentifier: aid)
                }
            }
        }
    }
    
    func onReadCardDataResponse(data: [String : String]) {
        let readCardDataResponse = ReadCardDataResponse(success: true, result: .SUCCESS)
        let goCardData = GoCardData()
        goCardData.emvtlvData = data[CardDataParameter.emvtlvData.toString()]
        goCardData.encryptedTrack = data[CardDataParameter.encryptedTrack.toString()]
        goCardData.ksn = data[CardDataParameter.ksn.toString()]
        goCardData.track2EquivalentData = data[CardDataParameter.track2EquivalentData.toString()]
        goCardData.cardholderName = data[CardDataParameter.cardHolderName.toString()]
        goCardData.exp = data[CardDataParameter.expDate.toString()] ?? data[CardDataParameter.applicationExpirationDate.toString()]
        goCardData.pan = data[CardDataParameter.pan.toString()]
        if let pan = goCardData.pan {
            goCardData.first6 = pan.prefix(6).description
            goCardData.last4 = pan.suffix(4).description
        }
        goCardData.track1 = data[CardDataParameter.track1Data.toString()]
        goCardData.track2 = data[CardDataParameter.track2Data.toString()]
        goCardData.cardType = data[CardDataParameter.cardType.toString()]
        readCardDataResponse.cardData = goCardData
        self.connectorListener?.onReadCardDataResponse(readCardDataResponse)
    }
    
}
