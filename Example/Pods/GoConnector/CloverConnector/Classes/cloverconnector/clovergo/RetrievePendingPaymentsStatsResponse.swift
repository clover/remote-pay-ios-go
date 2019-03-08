//
//  RetrievePendingPaymentsStatsResponse.swift
//  CloverConnector
//
//  Created by Veeramani, Rajan (Non-Employee) on 12/20/17.
//

import Foundation
import ObjectMapper

public class RetrievePendingPaymentsStatsResponse : BaseResponse {
    
    public var totalPaymentAmount : Int = 0
    public var noOfDaysOffline : Int = 0
    public var totalPaymentCount : Int = 0
    public var pendingPaymentCount : Int = 0
    public var failedPaymentCount : Int = 0
    
    public init(code:ResultCode, message:String) {
        super.init(success: code == ResultCode.SUCCESS, result: code);
    }
    
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
    }
}
