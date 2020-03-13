//  RJConversionCommon.m
//  RevJetSDK

//  Copyright (c) RevJet. All rights reserved.

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/ASIdentifierManager.h>

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

#import "RJConversionConfig.h"
#import "RJConversionCommon.h"
#import "RJConversionReachability.h"

#import "RJConversionTracker.h"

@implementation RJConversionCommon

NSString *conversionURLStr;

+ (NSString *)urlEncode:(id) str {
	NSString *string = [str description];
	return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*) addParamName:(NSString*)name value:(NSString*)value toString:(NSString*)str {
    if (name && value) {
        // param = (str.pos("?") != null ? "&" : "?") + urlEncode(name) + "=" + urlEncode(value)
        NSString* param = [([str rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&")
					stringByAppendingString:[[RJConversionCommon urlEncode:name] stringByAppendingString:
					[@"=" stringByAppendingString:[RJConversionCommon urlEncode:value]]]];
        str = [str stringByAppendingString:param];
    }
    return str;
}

+(NSString*) getUserAgent {
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* userAgent = [[webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy];
#ifdef DEBUG
    NSLog(@"### USER AGENT: %@", userAgent);
#endif
    return userAgent;
}

// full url is : {url} + did={uid}&appid={buindle_id}
+ (NSString *)conversionUrl
{
	if (nil == conversionURLStr)
	{
		NSString *theConversionUrl = kRJConversionURL;

		// add IFA
		Class theASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
		if (Nil != theASIdentifierManagerClass)
		{
			NSString *theIfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
			if (nil != theIfa)
			{
				theConversionUrl = [RJConversionCommon addParamName:@"_ifa" value:theIfa toString:theConversionUrl];
			}
		}
		  
		// Add Application Bundle ID (Physical ID)
		theConversionUrl = [RJConversionCommon addParamName:@"bundleid" value:[NSBundle mainBundle].bundleIdentifier
												   toString:theConversionUrl];
        
		// Add Application Bundle Version
		theConversionUrl = [RJConversionCommon                 addParamName:@"bundlever" value:[[NSBundle mainBundle]
					objectForInfoDictionaryKey:@"CFBundleVersion"] toString:theConversionUrl];
        
		// Add RevJet Library version
		theConversionUrl = [RJConversionCommon addParamName:@"libver" value:kRJConversionVersion toString:theConversionUrl];
        
		// Add Device Type
		theConversionUrl = [RJConversionCommon addParamName:@"dtype" value:[UIDevice currentDevice].model
												   toString:theConversionUrl];
        
		// Add System Version
		theConversionUrl = [RJConversionCommon addParamName:@"osver" value:[UIDevice currentDevice].systemVersion
												   toString:theConversionUrl];
        
		// Add System Name
		theConversionUrl = [RJConversionCommon addParamName:@"osname" value:[UIDevice currentDevice].systemName
												   toString:theConversionUrl];
        
		// Connection Type
		theConversionUrl = [RJConversionCommon addParamName:@"contype" value:[RJConversionCommon connectionType]
												   toString:theConversionUrl];
        
		conversionURLStr = theConversionUrl;
	}
    
	return conversionURLStr;
}

+(BOOL) createDirIfNotExistsForPath:(NSString *) path {
	BOOL isDirectory = YES;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    NSError* error = nil;
	if (!exists) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
#ifdef DEBUG
			NSLog( @"RevJetConversion:createDirIfNotExistsForPath:error = %@", [error description] );
#endif
            return NO; // couldn't create a folder
        }
	}
    return YES;
}

+ (NSString *) connectionType
{
    static NSString *type = nil;
    
    if ( type != nil ) {
        return type;
    }
    
    RJConversionReachabilityStatusType netStatus = [[RJConversionReachability reachabilityForLocalWiFi]
				currentReachabilityStatus];
    if ( netStatus != kRJConversionReachabilityStatusWiFi ) {
        netStatus = [[RJConversionReachability reachabilityForInternetConnection] currentReachabilityStatus];
    }
    
    switch ( netStatus ) {
        case kRJConversionReachabilityStatusWiFi:
            type = @"wifi";
            break;
            
        case kRJConversionReachabilityStatusWWAN:
            type = @"carrier";
            break;
            
        case kRJConversionReachabilityStatusNotReachable:
            type = @"none";
            break;
            
        default:
            type = @"unknown";
    }
    
    return type;
}

@end
