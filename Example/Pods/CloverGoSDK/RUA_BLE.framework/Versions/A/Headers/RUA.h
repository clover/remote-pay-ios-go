//
//  RUA.h
//  RUA
//
//  Created by Russell Kondaveti on 10/9/13.
//  Copyright (c) 2013 ROAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUADeviceManager.h"
#import "RUAReaderVersionInfo.h"

#define RUA_DEBUG 1
#ifdef RUA_DEBUG
#define RUA_DEBUG_LOG(...) NSLog(__VA_ARGS__)
#else
#define RUA_DEBUG_LOG(...)
#endif

static NSString *RUA_Version = @"1.7.3.9";

typedef void (^OnRepackageUNSFileHandler)(BOOL repackageSucceed);

@interface RUA : NSObject

/**
 Enables RUA log messages
 @param enable, TRUE to enable logging
 */
+ (void)enableDebugLogMessages:(BOOL)enable;

/**
 * Sets if the ROAMreaderUnifiedAPI has to operate in production mode.<br>
 *
 * By default, the production mode is enabled.
 *
 * Note: For now, debug logging cannot be enabled only if ROAMreaderUnified API is operating in production mode
 *
 * @param enable boolean to indicate that this is production mode
 *
 */
+ (void)setProductionMode:(BOOL)enable;

/**
 * Sets if the ROAMreaderUnifiedAPI has to post response on UI thread.<br>
 *
 * By default, the response will be posted on UI thread.
 *
 * @param enable boolean to post response on UI thread
 *
 */
+ (void)setPostResponseOnUIThread:(BOOL)postResponseOnUIThread;

/**
 Returns true if ROAMreaderUnifiedAPI has to post response on UI thread
 */
+ (BOOL)postResponseOnUIThread;

/**
 Returns true if RUA log messages are enabled
 */
+ (BOOL)debugLogEnabled;

/**
 Returns the list of roam device types that are supported by the RUA
 <p>
 Usage: <br>
 <code>
 NSArray *supportedDevices = [RUA getSupportedDevices];
 </code>
 </p>
 @return NSArray containing the enumerations of reader types that are supported.
 @see RUADeviceType
 */
+ (NSArray *)getSupportedDevices;

/**
 Returns an instance of the device manager for the connected device and this auto detection works with the readers that have audio jack interface.
 @param RUADeviceType roam reader type enumeration
 @return RUADeviceManager device manager for the device type specified
 @see RUADeviceType
 */
+ (id <RUADeviceManager> )getDeviceManager:(RUADeviceType)type;


/**
 Returns an instance of the device manager for the device type specified.
 <p>
 Usage: <br>
 <code>
 id<RUADeviceManager> mRP750xReader = [RUA getDeviceManager:RUADeviceTypeRP750x];
 </code>
 </p>
 @param RUADeviceType roam reader type enumeration
 @return RUADeviceManager device manager for the device type specified
 @see RUADeviceType
 */

+ (id <RUADeviceManager> )getAutoDetectDeviceManager:(NSArray*)type;

/**
 Returns an version of ROAMReaderUnifiedAPI (RUA)
 @return RUADeviceManager device manager for the device type specified
 */
+ (NSString *) versionString __deprecated_msg("use RUA_Version instead");

+ (BOOL)isUpdateRequired:(NSString*)filePath readerInfo:(RUAReaderVersionInfo*)readerVersionInfo;

/**
 * Returns a boolean to indicate if the UNS files need to be loaded onto the terminal.
 *
 * @return boolean to indicate if the UNS files need to be loaded onto the terminal
 * @see RUAReaderVersionInfo, RUAFileVersionInfo
 *
 */

+ (BOOL)isUpdateRequired:(NSArray*)UNSFiles readerVersionInfo:(RUAReaderVersionInfo*)readerVersionInfo;;

/**
 * Returns a list of file version descriptions for each file
 * contained within the specified UNS file.
 * @see RUAFileVersionInfo
 *
 */

+ (NSArray*)getUnsFileVersionInfo:(NSString*)filePath;

/**
 * Repackage the speicified UNS file with reader version info
 * @param fromFilePath original UNS file path (eg. /var/mobile/Containers/Data/Application/447B9EDB-0B3E-49F2-98A5-6B5674401C61/Documents/original.uns)
 * @param toFilePath file save path for the repackage UNS file (eg. /var/mobile/Containers/Data/Application/447B9EDB-0B3E-49F2-98A5-6B5674401C61/Documents/newfile.uns)
 * @param readerVersionInfo reader version information
 * @see RUAReaderVersionInfo
 *
 */
+ (void)repackageUNSFile:(NSString *)fromFilePath toFilePath:(NSString *)toFilePath andReaderVersion:(RUAReaderVersionInfo *)readerVersionInfo response:(OnRepackageUNSFileHandler)handler;

@end
