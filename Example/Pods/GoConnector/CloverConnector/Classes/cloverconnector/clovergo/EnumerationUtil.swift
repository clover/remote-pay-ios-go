//
//  EnumerationUtil.swift
//  CloverGoConnector
//
//  Created by Veeramani, Rajan (Non-Employee) on 4/25/17.
//  Copyright © 2017 Veeramani, Rajan (Non-Employee). All rights reserved.
//

import Foundation
import clovergoclient

class EnumerationUtil {
    
    class func CardTransactionType_toEnum(type:String) -> CLVModels.Payments.CardTransactionType? {
        switch type {
        case "AUTH":
            return .AUTH
        case "PREAUTH":
            return .PREAUTH
        case "PREAUTHCAPTURE":
            return .PREAUTHCAPTURE
        case "ADJUST":
            return .ADJUST
        case "VOID":
            return .VOID
        case "VOIDRETURN":
            return .VOIDRETURN
        case "RETURN":
            return .RETURN
        case "REFUND":
            return .REFUND
        case "NAKEDREFUND":
            return .NAKEDREFUND
        case "GETBALANCE":
            return .GETBALANCE
        case "BATCHCLOSE":
            return .BATCHCLOSE
        case "ACTIVATE":
            return .ACTIVATE
        case "BALANCE_LOCK":
            return .BALANCE_LOCK
        case "LOAD":
            return .LOAD
        case "CASHOUT":
            return .CASHOUT
        case "CASHOUT_ACTIVE_STATUS":
            return .CASHOUT_ACTIVE_STATUS
        case "REDEMPTION":
            return .REDEMPTION
        case "REDEMPTION_UNLOCK":
            return .REDEMPTION_UNLOCK
        case "RELOAD":
            return .RELOAD
        default:
            return nil
        }
    }
    
    class func CardType_toEnum(type:String) -> CLVModels.Payments.CardType {
        switch type {
        case "VISA":
            return .VISA
        case "MC":
            return .MC
        case "AMEX":
            return .AMEX
        case "DISCOVER":
            return .DISCOVER
        case "DINERS_CLUB":
            return .DINERS_CLUB
        case "JCB":
            return .JCB
        case "MAESTRO":
            return .MAESTRO
        case "SOLO":
            return .SOLO
        case "LASER":
            return .LASER
        case "CHINA_UNION_PAY":
            return .CHINA_UNION_PAY
        case "CARTE_BLANCHE":
            return .CARTE_BLANCHE
        case "GIFT_CARD":
            return .GIFT_CARD
        case "EBT":
            return .EBT
        default:
            return .UNKNOWN
        }
    }
    
    class func CardEntryType_toEnum(type:String) -> CLVModels.Payments.CardEntryType? {
        switch type {
        case "SWIPED":
            return .SWIPED
        case "KEYED":
            return .KEYED
        case "VOICE":
            return .VOICE
        case "VAULTED":
            return .VAULTED
        case "OFFLINE_SWIPED":
            return .OFFLINE_SWIPED
        case "OFFLINE_KEYED":
            return .OFFLINE_KEYED
        case "EMV_CONTACT":
            return .EMV_CONTACT
        case "EMV_CONTACTLESS":
            return .EMV_CONTACTLESS
        case "MSD_CONTACTLESS":
            return .MSD_CONTACTLESS
        case "PINPAD_MANUAL_ENTRY":
            return .PINPAD_MANUAL_ENTRY
        default:
            return nil
        }
    }
    
    class func CvmResult_toEnum(type:String) -> CLVModels.Payments.CvmResult? {
        switch type {
        case "NO_CVM_REQUIRED":
            return .NO_CVM_REQUIRED
        case "SIGNATURE":
            return .SIGNATURE
        case "PIN":
            return .PIN
        case "ONLINE_PIN":
            return .ONLINE_PIN
        case "SIGNATURE_AND_PIN":
            return .SIGNATURE_AND_PIN
        case "CVM_FAILED":
            return .CVM_FAILED
        case "DEVICE":
            return .DEVICE
        default:
            return nil
        }
    }
    
    class func VoidReason_toString(type:VoidReason) -> String? {
        switch type {
        case .AUTH_CLOSED_NEW_CARD:
            return "AUTH_CLOSED_NEW_CARD"
        case .DEVELOPER_PAY_PARTIAL_AUTH:
            return "DEVELOPER_PAY_PARTIAL_AUTH"
        case .FAILED:
            return "FAILED"
        case .NOT_APPROVED:
            return "NOT_APPROVED"
        case .REJECT_DUPLICATE:
            return "REJECT_DUPLICATE"
        case .REJECT_PARTIAL_AUTH:
            return "REJECT_PARTIAL_AUTH"
        case .REJECT_SIGNATURE:
            return "REJECT_SIGNATURE"
        case .TRANSPORT_ERROR:
            return "TRANSPORT_ERROR"
        case .USER_CANCEL:
            return "USER_CANCEL"
        }
    }
    
    class func TransactionEvent_toGoReaderTransactionEvent(event:TransactionEvent) -> CLVModels.Payments.GoTransactionEvent? {
        switch event {
        case .card_swiped:
            return .CARD_SWIPED
        case .card_tapped:
            return .CARD_TAPPED
        case .contactless_failed_try_again:
            return .CONTACTLESS_FAILED_TRY_AGAIN
        case .emv_card_dip_failed:
            return .EMV_CARD_DIP_FAILED
        case .emv_card_inserted:
            return .EMV_CARD_INSERTED
        case .emv_card_removed:
            return .EMV_CARD_REMOVED
        case .emv_card_swiped_error:
            return .EMV_CARD_SWIPED_ERROR
        case .emv_dip_failed_3_attempts:
            return .EMV_DIP_FAILED_PROCEED_WITH_SWIPE
        case .swipe_dip_tap_card:
            return .SWIPE_DIP_OR_TAP_CARD
        case .swipe_failed:
            return .SWIPE_FAILED
        case .remove_card:
            return .REMOVE_CARD
        case .processing_transaction:
            return .PROCESSING_TRANSACTION
        case .multiple_contactless_cards_detected:
            return .MULTIPLE_CONTACTLESS_CARDS_DETECTED
        case .contactless_failed_try_contact:
            return .CONTACTLESS_FAILED_TRY_CONTACT
        case .please_see_phone:
            return .PLEASE_SEE_PHONE
        }
    }
    
    class func CardReaderType_toGoReaderType(type:ReaderInfo.CardReaderType) -> CLVModels.Device.GoDeviceType {
        switch type {
        case .RP350:
            return .RP350
        case .RP450:
            return .RP450
        }
    }
    
    class func GoReaderType_toCardReaderType(type:CLVModels.Device.GoDeviceType) -> ReaderInfo.CardReaderType {
        switch type {
        case .RP350:
            return .RP350
        case .RP450:
            return .RP450
        }
    }
    
    class func TransactionState_toGoPendingPaymentState(state:OfflineTransactionState) -> GoPendingPaymentEntry.PendingPaymentState {
        switch state {
        case .failed:
            return GoPendingPaymentEntry.PendingPaymentState.FAILED
        case .pending:
            return GoPendingPaymentEntry.PendingPaymentState.PENDING
        case .unknown:
            return GoPendingPaymentEntry.PendingPaymentState.UNKNOWN
        case .inprogress:
            return GoPendingPaymentEntry.PendingPaymentState.PROCESSING
        }
    }
    
    class func CardReaderInitializationEvent_toGoDeviceInitializationEvent(event: CardReaderInitializationEvent) -> CLVModels.Device.GoDeviceInitializationEvent {
        switch event {
        case .clear_aid_pk_complete, .aid_flush_complete, .public_key_flush_complete,.dol_flush_complete:
            return .LOADING_TERMINAL_PARAMS
        case .initialization_complete:
            return .INITIALIZATION_COMPLETE
        case .downloading_firmware:
            return .DOWNLOADING_FIRMWARE
        case .firware_download_complete:
            return .FIRMWARE_DOWNLOAD_COMPLETE
        case .updating_firmware:
            return .UPDATING_FIRMWARE
        case .firmware_update_complete:
            return .FIRMWARE_UPDATE_COMPLETE
        }
    }
    
    class func CardReaderErrorEvent_toGoDeviceErrorEvent(event: CardReaderErrorEvent) -> CLVModels.Device.GoDeviceErrorEvent{
        switch event {
        case .initialization_failed:
            return .INITIALIZATION_FAILED
        case .reader_data_not_avaliable:
            return .TERMINAL_PARAMS_NOT_AVAILABLE
        case .firmware_download_failed:
            return .FIRMWARE_DOWNLOAD_FAILED
        case .firmware_update_failed:
            return .FIRMWARE_UPDATE_FAILED
        case .firmware_update_not_supported:
            return .FIRMWARE_UPDATE_NOT_SUPPORTED
        }
    }
}
