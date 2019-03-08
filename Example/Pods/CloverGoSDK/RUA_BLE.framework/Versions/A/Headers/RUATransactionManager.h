//
//  ReaderTransactionManager.h
//  ROAMreaderUnifiedAPI
//
//  Created by Russell Kondaveti on 10/9/13.
//  Copyright (c) 2013 ROAM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RUADeviceResponseHandler.h"
#import "RUACommand.h"


#ifndef RUATransactionManager_h
#define RUATransactionManager_h

@protocol RUATransactionManager <NSObject>


/**
 This is an Asynchronous method that sends the read magnetic stripe command to the reader.
 The reader waits for the magnetic card swipe and when the reader detects a card swipe , it returns the result as a map to the OnResponse block passed.<br>
 @param response OnResponse block
 @param progress OnProgress block
 @see RUAParameter, RUADeviceResponseHandler
 */
- (void)waitForMagneticCardSwipe:(OnProgress)progress response:(OnResponse)response;

/**
 Stops the reader from waiting for magnetic card swipe.
 */
- (void)stopWaitingForMagneticCardSwipe;

/**
 This is an Asynchronous method that sends the transaction command to the roam reader.<br>
 When the reader processes the command, it returns the result as a map to the OnResponse block passed.<br>
 <p>
 Usage:
 <code>
 RUADeviceManager deviceManager; <br>
 ....<br>
 NSMutableDictionary* transactionParameters = [[NSMutableDictionary alloc] init];
 [transactionParameters setObject:[RUAEnumerationHelper RUACommand_toString:RUACommandEMVStartTransaction] forKey:[NSNumber numberWithInt:RUAParameterCommand]];
 [transactionParameters setObject:@"0826" forKey:[NSNumber numberWithInt:RUAParameterTransactionCurrencyCode]];
 [transactionParameters setObject:@"00" forKey:[NSNumber numberWithInt:RUAParameterTransactionType]];
 [transactionParameters setObject:@"000100000000" forKey:[NSNumber numberWithInt:RUAParameterAmountAuthorizedNumeric]];
 [transactionParameters setObject:@"000000000000" forKey:[NSNumber numberWithInt:RUAParameterAmountOtherNumeric]];
 [transactionParameters setObject:@"030507" forKey:[NSNumber numberWithInt:RUAParameterTransactionDate]];
 [transactionParameters setObject:@"0826" forKey:[NSNumber numberWithInt:RUAParameterTerminalCountryCode]];
 [transactionParameters setObject:@"E0B8C8" forKey:[NSNumber numberWithInt:RUAParameterTerminalCapabilities]];
 [transactionParameters setObject:@"22" forKey:[NSNumber numberWithInt:RUAParameterTerminalType]];
 [transactionParameters setObject:@"F000F0A001" forKey:[NSNumber numberWithInt:RUAParameterAdditionalTerminalCapabilities]];
 [transactionParameters setObject:@"9F3704" forKey:[NSNumber numberWithInt:RUAParameterDefaultValueForDDOL]];
 [transactionParameters setObject:@"59315A3159325A3259335A333030303530313034" forKey:[NSNumber numberWithInt:RUAParameterAuthorizationResponseCodeList]];
 [transactionParameters setObject:@"03" forKey:[NSNumber numberWithInt:RUAParameterTerminalConfiguration]];
 [transactionParameters setObject:dateStr forKey:[NSNumber numberWithInt:RUAParameterTransactionTime]];
 [transactionParameters setObject:@"00" forKey:[NSNumber numberWithInt:RUAParameterPOSEntryMode]];
 [transactionParameters setObject:@"0000" forKey:[NSNumber numberWithInt:RUAParameterMerchantCategoryCode]];
 [transactionParameters setObject:@"0000000000000000" forKey:[NSNumber numberWithInt:RUAParameterTerminalIdentification]];
 [transactionParameters setObject:@"00110321" forKey:[NSNumber numberWithInt:RUAParameterTransactionSequenceCounter]];
 [[deviceManager getTransactionManager] sendCommand:RUACommandEMVStartTransaction withParameters:[processor getEMVStartTransactionParameters] progress:^(RUAProgressMessage messageType) {
 }
 response:^(RUAResponse *ruaResponse) {
 
 }
 ];
 </code>
 </p><p>
 For EMVStartTransaction Command, the valid input parameters are as below:<br>
 - RUAParameterCommand (Mandatory)<br>
 - RUAParameterTransactionCurrencyCode (Mandatory)<br>
 - RUAParameterTransactionType (Mandatory)<br>
 - RUAParameterTerminalConfiguration (Mandatory)<br>
 - RUAParameterTransactionDate (Mandatory)<br>
 - RUAParameterTerminalCapabilities (Mandatory)<br>
 - RUAParameterTerminalType (Mandatory)<br>
 - RUAParameterAdditionalTerminalCapabilities (Mandatory)<br>
 - RUAParameterDefaultValueForDDOL (Mandatory)<br>
 - RUAParameterAuthorizationResponseCodeList (Mandatory)<br>
 - RUAParameterAmountAuthorizedBinary (Optional)<br>
 - RUAParameterAmountOtherBinary (Optional)<br>
 - RUAParameterTerminalCountryCode (Optional)<br>
 - RUAParameterTransactionCurrencyExponent (Optional)<br>
 - RUAParameterAmountAuthorizedNumeric (Optional)<br>
 - RUAParameterAmountOtherNumeric (Optional)<br>
 <br>
 The map passed to the onResponse callback contains the following parameters, <br>
 - RUAParameterResponseCode (ResponseCode enumeration as value) <br>
 - RUAParameterErrorCode (if not successful, ErrorCode enumeration as value) <br>
 - RUAParameterKSN (String as value)<br>
 - RUAParameterEncryptedTrack(String as value)<br>
 The map also includes the EMV parameters configured through setAmountDOL.<br>
 </p><p>
 For EMVTransactionData Command, the valid input parameters are as below:<br>
 - RUAParameterCommand (Mandatory)<br>
 - RUAParameterThresholdvalue (Mandatory)<br>
 - RUAParameterTargetpercentage (Mandatory)<br>
 - RUAParameterMaximumtargetpercentage (Mandatory)<br>
 - RUAParameterTerminalActionCodeDefault (Mandatory)<br>
 - RUAParameterTerminalActionCodeDenial (Mandatory)<br>
 - RUAParameterTerminalActionCodeOnline (Mandatory)<br>
 - RUAParameterTerminalFloorLimit (Mandatory)<br>
 - RUAParameterAmountAuthorizedBinary (Optional)<br>
 - RUAParameterAmountAuthorizedNumeric (Optional)<br>
 - RUAParameterAmountOtherBinary (Optional)<br>
 - RUAParameterAmountOtherNumeric (Optional)<br>
 - RUAParameterAmountOfLasttransactionWithSameCard (Optional)<br>
 - RUAParameterCardIsInTheHotlist (Optional)<br>
 - RUAParameterTransactionForcedOnline (Optional)<br>
 - RUAParameterTerminalCountryCode (Optional)<br>
 - RUAParameterTerminalCapabilities (Optional)<br>
 - RUAParameterDefaultValueForDDOL (Optional)<br>
 - RUAParameterDefaultValueForTDOL (Optional)<br>
 - RUAParameterPINEntryDisplayPromptString (Optional)<br>
 - RUAParameterVerificationonlyTransactionFlag (Optional)<br>
 - RUAParameterOnlinePINBlockKeyLocator (Optional)<br>
 - RUAParameterOnlinePINBlockFormat (Optional)<br>
 - RUAParameterMACDOL (Optional)<br>
 - RUAParameterMACData (Optional)<br>
 - RUAParameterMACInitialisationVector (Optional)<br>
 <br>
 The map passed to the onResponse callback contains the following parameters. <br>
 - RUAParameterResponseCode (ResponseCode enumeration as value) <br>
 - RUAParameterErrorCode (if not successful, ErrorCode enumeration as value) <br>
 - RUAParameterKSN (String as value)<br>
 - RUAParameterEncryptedTrack(String as value)<br>
 The map also includes the EMV parameters configured through setOnlineDOL.<br>
 </p><p>
 For EMVCompleteTransaction Command, the valid input parameters are as below,<br>
 - RUAParameterCommand (Mandatory)<br>
 - RUAParameterResultofOnlineProcess (Mandatory)<br>
 - RUAParameterIssuerScript1 (Optional)<br>
 - RUAParameterIssuerScript2 (Optional)<br>
 - RUAParameterWrapperforIssuerScriptTagWithIncorrectLength (Optional)<br>
 - RUAParameterAuthorizationCode (Optional)<br>
 - RUAParameterAuthorizationResponseCode (Optional)<br>
 - RUAParameterIssuerAuthenticationData (Optional)<br>
 - RUAParameterAuthorizationResponseCodeList (Optional)<br>
 <br>
 The map passed to the onResponse callback contains the following parameters and the data for EMV tag DOLs configured, <br>
 - RUAParameterResponseCode (ResponseCode enumeration as value) <br>
 - RUAParameterErrorCode (if not successful, ErrorCode enumeration as value) <br>
 - RUAParameterKSN (String as value)<br>
 - RUAParameterEncryptedTrack(String as value)<br>
 The map also includes the EMV parameters configured through setResponseDOL.<br>
 </p><p>
 For EMVTransactionStop Command, the valid input parameters are as below, <br>
 - RUAParameterCommand (Mandatory)<br>
 - RUAParameterAlternateMessageForRemoveCardPrompt (Optional)<br>
 - RUAParameterContactlessSignatureCheckResult (Optional)<br>
 <br>
 The map passed to the onResponse callback contains the following parameters, <br>
 - RUAParameterResponseCode (ResponseCode enumeration as value) <br>
 - RUAParameterErrorCode (if not successful, ErrorCode enumeration as value) <br>
 </p><p>
 For EMVFinalApplicationSelection Command, the valid input parameters are as below,<br>
 - RUAParameterCommand (Mandatory)<br>
 - RUAParameterApplicationIdentifier (Mandatory)<br>
 <br>
 The map passed to the onResponse callback contains the following parameters, <br>
 - RUAParameterResponseCode (ResponseCode enumeration as value) <br>
 - RUAParameterErrorCode (if not successful, ErrorCode enumeration as value) <br>
 - RUAParameterKSN (String as value)<br>
 - RUAParameterEncryptedTrack(String as value)<br>
 </p>
 @param parameters input map containing the input reader parameters
 @param response OnResponse block
 @param progress OnProgress block
 @see RUAParameter, RUACommand
 */
- (void)sendCommand:(RUACommand)command withParameters:(NSDictionary *)parameters progress:(OnProgress)progress response:(OnResponse)response;

/**
 * Cancels any one of the previously issued commands,
 * <ul>
 * <li>EMVStartTransaction</li>
 * <li>WaitForMagneticCardSwipe</li>
 * <li>ReadKeypad</li>
 * <li>KeyPadControl</li>
 * </ul>
 * Unlike other commands, this command will not receive a response,
 * even if there is no outstanding command to be cancelled.
 */
- (void)cancelLastCommand;

/**
 * This command will make the card reader wait until the card is fully removed or if the timeout expires before returning a response.
 * @param cardRemovalTimeout timeout period for card removal in seconds.<br> Range 1 - 65 <br> 0 - indefinite wait
 * @param response OnResponse block
 */
- (void)waitForCardRemoval:(NSInteger)cardRemovalTimeout response:(OnResponse)response;

@end

#endif /* ifndef RUATransactionManager_h */
