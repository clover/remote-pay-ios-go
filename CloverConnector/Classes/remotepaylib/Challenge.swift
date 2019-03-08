//
//  Challenge.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

import ObjectMapper
//import CloverSDK

public class Challenge : Mappable {
    public var message:String?
    public var reason:VoidReason?
    public var type:ChallengeType?
    
    public init() {}
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        message <- map["message"]
        reason <- map["reason"]
        type <- map["type"]
    }
}

public enum ChallengeType : String {
    case DUPLICATE_CHALLENGE = "DUPLICATE_CHALLENGE"
    case OFFLINE_CHALLENGE = "OFFLINE_CHALLENGE"
    case PARTIAL_AUTH_CHALLENGE = "PARTIAL_AUTH_CHALLENGE"
    case AVS_FAILURE_CHALLENGE = "AVS_FAILURE_CHALLENGE"
    case OFFLINE_THRESHOLD_LIMIT_EXCEEDED_CHALLENGE = "OFFLINE_THRESHOLD_LIMIT_EXCEEDED_CHALLENGE"
    case CVV_MISMATCH_CHALLENGE = "CVV_MISMATCH_CHALLENGE"
}
