//
//  LandiCommandHelper.h
//  ROAMreaderUnifiedAPI
//
//  Created by Russell Kondaveti on 10/19/13.
//  Copyright (c) 2013 ROAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUA.h"
#import "RUAPublicKey.h"
#import "RUAApplicationIdentifier.h"
#import "RUAByteUtils.h"
#import "RUAParameter.h"
#import "RUACommand.h"
#import "RUAEnumerationHelper.h"

typedef struct TLV {
	RUAParameter parameter;
	NSString *code;
	u_int32_t minLen;
	u_int32_t maxLen;
    RUAValueFormat valueFormat;
    BOOL isProprietary;
} RUAParameterTLV;

@interface RUACommandHelper : NSObject

+ (NSData *)getBatteryInfoCommand;
+ (NSData *)getCancelWaitCommand;
+ (NSData *)getClearAIDsListCommand;
+ (NSData *)getClearPubliKeysCommand;
+ (NSData *)getConfigureDOLListCommand:(RUACommand)cmd withDataObjectList:(NSArray *)dols;
+ (NSData *)getEncryptedDataStatusCommand;
+ (NSData *)getGenerateBeepCommand;
+ (NSData *)getReadCapabilitiesCommand;
+ (NSData *)getReadMagStripeCommand;
+ (NSData *)getReadVersionCommand;
+ (NSData *)getReadKeyMappingInformation;
+ (NSData *)getReadCertificateFilesVersion;
+ (NSData *)getEnableRKIModeCommand;
+ (NSData *)getResetReaderCommand;
+ (NSData *)getRetrieveKSNCommand;
+ (NSData *)getEnableContactessCommand;
+ (NSData *)getEnableFirmwareUpdateCommand;
+ (NSData *)getDisableContactessCommand;
+ (NSData *)getDeviceStatisticsCommand;
+ (NSData *)getWaitForCardRemovalCommand:(NSInteger)cardRemovalTimeout;
+ (NSString *)getRUAParameterCode:(RUAParameter)paramter;
+ (int)getRUAParameterMaxLength:(RUAParameter)paramter;
+ (int)getRUAParameterMinLength:(RUAParameter)paramter;
+ (RUAParameter)getRUAParameter:(NSString *)emvTag;
+ (NSString *)getRUAParameterMaxLengthString:(RUAParameter)paramter;
+ (NSString *)getRUAParameterMinLengthString:(RUAParameter)paramter;
+ (BOOL)isRUAParameterLengthVariable:(RUAParameter)paramter;
+ (BOOL)isRUAParameterProprietary:(RUAParameter)paramter;
+ (RUAValueFormat)getRUAValueFormat:(RUAParameter)paramter;
+ (NSData *)getSubmitPublicKeyListCommand:(RUAPublicKey *)key;
+ (NSData *)getRevokePublicKeyListCommand:(RUAPublicKey *)key;
+ (NSData *)getSubmitAIDSListCommand:(NSArray *)aids forCommand:(RUACommand) command;
+ (NSData *)getTransactionCommand:(RUACommand)cmd withInputParameters:(NSDictionary *)input;
+ (NSData *)getLoadSessionKeyCommand:(int) keyLength
                 withSessionKeyLocator: (NSString *) sessionKeyLocator
                  withMasterKeyLocator: (NSString *) masterKeyLocator
                      withEncryptedKey: (NSString *) encryptedKey
                        withCheckValue: (NSString *) checkValue
                                withId: (NSString *) ID;

+ (NSData *)getEnergySaverTimeCommand:(int)seconds;

+ (NSData *)getShutDownModeTimeCommand:(int)seconds;

+ (NSData *)retrieveCommandToSetFirmwareType:(RUAFirmwareType)firmwareType withVersionString:(NSString*)versionString;

+ (NSData *)retrieveCommandToGetVersionForFirmwareType:(RUAFirmwareType)firmwareType;

+ (NSData *)getCommandToConfigureReadMagneticCardBeep:(BOOL)disableReadMagneticCardBeep removeCardBeep:(BOOL)disableRemoveCardBeep andEMVStartTransactionBeep:(BOOL)disableEMVStartTransactionBeep;

+ (RUAErrorCode)getRUAErrorCode:(NSString *)readerError;

+ (NSData *)getKeyedCardData;

/**
 Description of dictionary containing RUA parameters and values
 @param String description of parameter dictionary
 @return Dictionary of RUA parameters and values
 @see RUAProgressMessage
 */
+ (NSString *)RUADescriptionOfParameters:(NSDictionary*)parameters;

@end
