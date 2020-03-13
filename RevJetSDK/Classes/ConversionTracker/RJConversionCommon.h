//  RJConversionCommon.h
//  RevJetSDK

//  Copyright (c) RevJet. All rights reserved.

#import <Foundation/Foundation.h>

//! Utility class for creating conversion URL and cookie logic.
@interface RJConversionCommon : NSObject

+ (NSString*)urlEncode:(id)aString;
+ (NSString*)addParamName:(NSString *)aName value:(NSString *)aValue toString:(NSString *)aString;
+ (NSString*)getUserAgent;

+ (NSString *)conversionUrl;
+ (NSString *)connectionType;


@end