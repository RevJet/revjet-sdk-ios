//
//  RJSlotURL.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/ASIdentifierManager.h>

#import "RJURL.h"

#import "RJSlot.h"
#import "RJSlotView.h"
#import "RJNetwork.h"
#import "RJSlotDelegate.h"
#import "RJReachability.h"

#import "RJUtilities.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "RJVASTRepresentationUtilities.h"

@interface RJURL()

+ (NSString *)urlEncode:(id)str;
+ (NSString *)connectionType;
+ (NSString *)platform;
+ (NSString *)carrierName;

+ (NSString *)stringURLFromParameters:(NSDictionary *)aParameters stringURL:(NSString *)aStringURL;

//! Returns carrier code parameter in the following format: "<mobile network code>-<mobile network name>"
+ (NSString *)carrierCode;

+ (CTCarrier *)subscriberCarrier;

+ (NSInteger)lengthForTargetingValue:(NSString *)aValue;

+ (NSString *)parameterForIntegrationType:(RJIntegrationType)aType;

@end

@interface NSObject (RJASIdentifierManagerClass)

+ (id)sharedManager;
- (id)advertisingIdentifier;
- (NSString *)UUIDString;
- (BOOL)isAdvertisingTrackingEnabled;

@end

@implementation RJURL

+ (NSMutableDictionary *)parametersForSlot:(NSString *)aSlotTag {
	if (nil == aSlotTag)
	{
		return nil;
	}

	NSBundle *theBundle = [NSBundle mainBundle];

	NSString *theLibraryType = @"src";
#ifdef REVJET_BINARY_SDK
	theLibraryType = @"bin";
#endif

	NSMutableDictionary *theParameters = [NSMutableDictionary dictionary];
	theParameters[@"_mraid"] = kRJMRAIDVersion;

	theParameters[@"_video_type"] = kRJVASTVersion;
	NSString *theVideoMimeTypes = [RJVASTRepresentationUtilities supportedVideoTypesSeparatedByComma];
	if (nil != theVideoMimeTypes)
	{
		theParameters[@"_video_mime_types"] = theVideoMimeTypes;
	}
	theParameters[@"_video_linearity"] = @"0";
	theParameters[@"_video_mindur"] = @"1";

	NSString *theBundleID = theBundle.bundleIdentifier;
	if (nil != theBundleID)
	{
		theParameters[@"bundleid"] = theBundleID;
	}
	NSString *theAppName = [theBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (nil != theAppName)
	{
		theParameters[@"appname"] = theAppName;
	}
	NSString *theBundleVersion = [theBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (nil != theBundleVersion)
	{
		theParameters[@"bundlever"] = theBundleVersion;
	}
	if (nil != kRJSDKVersion)
	{
		theParameters[@"libver"] = kRJSDKVersion;
	}
	if (nil != theLibraryType)
	{
		theParameters[@"libtype"] = theLibraryType;
	}
	NSString *theDeviceModel = [UIDevice currentDevice].model;
	if (nil != theDeviceModel)
	{
		theParameters[@"dtype"] = theDeviceModel;
	}
	NSString *theSystemVersion = [UIDevice currentDevice].systemVersion;
	if (nil != theSystemVersion)
	{
		theParameters[@"osver"] = theSystemVersion;
	}
	NSString *theSystemName = [UIDevice currentDevice].systemName;
	if (nil != theSystemName)
	{
		theParameters[@"osname"] = theSystemName;
	}
	NSString *theLocale = [[NSLocale currentLocale] localeIdentifier];
	if (nil != theLocale)
	{
		theParameters[@"locale"] = theLocale;
	}
	NSString *theLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
	if (nil != theLanguage)
	{
		theParameters[@"language"] = theLanguage;
	}
	NSString *theConnectionType = [self connectionType];
	if (nil != theConnectionType)
	{
		theParameters[@"contype"] = theConnectionType;
	}
	NSString *thePlatform = [self platform];
	if (nil != thePlatform)
	{
		theParameters[@"device"] = thePlatform;
	}

	NSString *theIFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	if (nil != theIFA)
	{
		theParameters[@"_ifa"] = theIFA;
	}

	int theDoNotTrackValue = ![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
	NSString *theDNTValue = [NSString stringWithFormat:@"%d", theDoNotTrackValue];
	if (nil != theDNTValue)
	{
		theParameters[@"dnt"] = theDNTValue;
	}

	NSString *theCarrierName = [RJURL carrierName];
	if ([theCarrierName length] > 0)
	{
		[theParameters setValue:theCarrierName forKey:@"carrier"];
	}

	NSString *theCarrierCode = [RJURL carrierCode];
	if ([theCarrierCode length] > 0)
	{
		[theParameters setValue:theCarrierCode forKey:@"carrier_code"];
	}

	NSArray *theComponents = [theSystemVersion componentsSeparatedByString:@"."];
	BOOL arbitraryLoads = NO;
	NSDictionary *theTransportSecurity = [theBundle objectForInfoDictionaryKey:@"NSAppTransportSecurity"];
	if ([theTransportSecurity isKindOfClass:[NSDictionary class]])
	{
		arbitraryLoads = [theTransportSecurity[@"NSAllowsArbitraryLoads"] boolValue];
	}
	if (0 != [theComponents count] && [theComponents[0] intValue] >= 9 && !arbitraryLoads)
	{
		theParameters[@"__scheme"] = @"https";
	}

	return theParameters;
}

+ (NSString *)urlForSlot:(RJSlot *)aSlot
{
	if (nil == aSlot)
	{
		return nil;
	}

	NSMutableDictionary *theParameters = [NSMutableDictionary dictionaryWithDictionary:
				[RJURL targetingParametersForSlot:aSlot]];
	
	if (aSlot.network.useRequestId && ([aSlot.network.requestId length] > 0))
	{
		[theParameters setValue:aSlot.network.requestId forKey:@"__orig_request"];
	}

	NSString *theURL = nil;
	if (nil != aSlot)
	{
		if (nil != aSlot.tagUrl)
		{
			theURL = [self stringURLForSlotTag:aSlot.tagUrl];
			theURL = [self stringURLFromParameters:theParameters stringURL:theURL];
		}
	}

	return theURL;
}

+ (NSString *)stringURLForSlotTag:(NSString *)aSlotTag
{
	if (nil == aSlotTag)
	{
		return nil;
	}

	NSBundle *theBundle = [NSBundle mainBundle];
	NSString *theSystemVersion = [UIDevice currentDevice].systemVersion;

	NSMutableDictionary *theParameters = [RJURL parametersForSlot:aSlotTag];

	NSString *theURL = [self stringURLFromParameters:theParameters stringURL:aSlotTag];
	
	NSArray *theComponents = [theSystemVersion componentsSeparatedByString:@"."];
	BOOL arbitraryLoads = NO;
	NSDictionary *theTransportSecurity = [theBundle objectForInfoDictionaryKey:@"NSAppTransportSecurity"];
	if ([theTransportSecurity isKindOfClass:[NSDictionary class]])
	{
		arbitraryLoads = [theTransportSecurity[@"NSAllowsArbitraryLoads"] boolValue];
	}
	if (0 != [theComponents count] && [theComponents[0] intValue] >= 9 && !arbitraryLoads)
	{
		NSRange theRange = [theURL rangeOfString:@"http://"];
		if (NSNotFound != theRange.location)
		{
			theURL = [theURL stringByReplacingCharactersInRange:theRange withString:@"https://"];
		}
	}

	return theURL;
}

+ (NSString *)stringURLWithTargetingForSlotTag:(NSString *)aSlotTag slot:(RJSlot *)aSlot
{
	NSString *theURL = [RJURL stringURLForSlotTag:aSlotTag];
	NSDictionary *theTargetingParameters = [RJURL targetingParametersForSlot:aSlot];
	theURL = [self stringURLFromParameters:theTargetingParameters stringURL:theURL];
	return theURL;
}

+ (NSString *)stringURLFromParameters:(NSDictionary *)aParameters stringURL:(NSString *)aStringURL
{
	NSMutableString *theURL = [NSMutableString stringWithString:aStringURL];
	for (NSString *theKey in [aParameters keyEnumerator])
	{
		if (NSNotFound == [theURL rangeOfString:@"?"].location)
		{
			[theURL appendString:@"?"];
		}
		else
		{
			[theURL appendString:@"&"];
		}
		
		NSString *theEncodeKey = [self urlEncode:theKey];
		NSString *theEncodeValue = [self urlEncode:aParameters[theKey]];
		if ((nil != theEncodeKey) && (nil != theEncodeValue))
		{
			[theURL appendString:theEncodeKey];
			[theURL appendString:@"="];
			[theURL appendString:theEncodeValue];
		}
	}
	
	return theURL;
}

+ (NSString *)slotTagFromSlotURL:(NSString *)aSlotURL
{
	if (nil == aSlotURL)
	{
		return nil;
	}
	
	NSString *theSlotTag = nil;
	NSString *theLastPathComponent = [aSlotURL lastPathComponent];
	NSArray *theComponents = [theLastPathComponent componentsSeparatedByString:@"?"];
	if ([theComponents count] > 0)
	{
		theLastPathComponent = theComponents[0];
		if (NSNotFound != [theLastPathComponent rangeOfString:@"slot"].location)
		{
			theSlotTag = theLastPathComponent;
		}
	}
	return theSlotTag;
}

+ (NSDictionary *)targetingParametersForSlot:(RJSlot *)aSlot
{
	NSMutableDictionary *theParameters = [NSMutableDictionary dictionary];
	if ([aSlot.delegate respondsToSelector:@selector(areaCode)])
	{
		NSString *theAreaCode = [aSlot.delegate areaCode];
		if ([self lengthForTargetingValue:theAreaCode] > 0)
		{
			theParameters[@"areacode"] = theAreaCode;
		}
	}

	if ([aSlot.delegate respondsToSelector:@selector(city)])
	{
		NSString *theCity = [aSlot.delegate city];
		if ([self lengthForTargetingValue:theCity] > 0)
		{
			theParameters[@"city"] = theCity;
		}
	}

	if ([aSlot.delegate respondsToSelector:@selector(country)])
	{
		NSString *theCountry = [aSlot.delegate country];
		if ([self lengthForTargetingValue:theCountry] > 0)
		{
			theParameters[@"country"] = theCountry;
		}
	}

	if ([aSlot.delegate respondsToSelector:@selector(hasLocation)] && [aSlot.delegate hasLocation])
	{
		if ([aSlot.delegate respondsToSelector:@selector(latitude)])
		{
			double theLatitude = [aSlot.delegate latitude];
			theParameters[@"lat"] = [NSString stringWithFormat:@"%lf", theLatitude];
		}

		if ([aSlot.delegate respondsToSelector:@selector(longitude)])
		{
			double theLongitude = [aSlot.delegate longitude];
			theParameters[@"long"] = [NSString stringWithFormat:@"%lf", theLongitude];
		}
	}

	if ([aSlot.delegate respondsToSelector:@selector(metro)])
	{
		NSString *theMetro = [aSlot.delegate metro];
		if ([self lengthForTargetingValue:theMetro] > 0)
		{
			theParameters[@"metro"] = theMetro;
		}
	}

	if ([aSlot.delegate respondsToSelector:@selector(zip)])
	{
		NSString *theZIP = [aSlot.delegate zip];
		if ([self lengthForTargetingValue:theZIP] > 0)
		{
			theParameters[@"zip"] = theZIP;
		}
	}

	if ([aSlot.delegate respondsToSelector:@selector(region)])
	{
		NSString *theRegion = [aSlot.delegate region];
		if ([self lengthForTargetingValue:theRegion] > 0)
		{
			theParameters[@"region"] = theRegion;
		}
	}

	if ([aSlot.delegate respondsToSelector:@selector(gender)])
	{
		NSString *theGender = [aSlot.delegate gender];
		if ([self lengthForTargetingValue:theGender] > 0)
		{
			theParameters[@"gender"] = theGender;
		}
	}
	
	// Integration parameter
	RJIntegrationType theIntegrationType = aSlot.view.integrationType;
	NSString *theIntegrationTypeParameter = [RJURL parameterForIntegrationType:theIntegrationType];
	if (nil != theIntegrationTypeParameter)
	{
		theParameters[@"_src"] = theIntegrationTypeParameter;
	}
	
	// smart banners
	if ([RJUtilities isSmartBanner:aSlot.tagUrl])
	{
		CGSize theSize = [RJUtilities supportedSizeForSize:aSlot.view.frame.size];
		NSString *theSizeString = [RJUtilities stringForSize:theSize];
		if (nil != theSizeString)
		{
			theParameters[@"ad_size"] = theSizeString;
		}
	}
	
	return theParameters;
}

#pragma mark -

+ (NSString *)urlEncode:(id)str
{
	CFStringRef result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
				(__bridge CFStringRef)str, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
	return (__bridge_transfer id)result;
}

+ (NSString *)connectionType {
  static NSString *type = nil;

  if (type != nil) {
    return type;
  }

  NetworkStatus netStatus = [[RJReachability reachabilityForLocalWiFi] currentReachabilityStatus];
  if (netStatus != ReachableViaWiFi) {
    netStatus = [[RJReachability reachabilityForInternetConnection] currentReachabilityStatus];
  }

  switch (netStatus) {
    case ReachableViaWiFi:
      type = @"wifi";
      break;

    case ReachableViaWWAN:
      type = @"carrier";
      break;

    case NotReachable:
      type = @"none";
      break;

    default:
      type = @"unknown";
  }

  return type;
}

typedef struct {
  char * code;
  char * machine;
} kRJHWPlatform;

static const kRJHWPlatform platforms[] = {
  {"iphone1", "iPhone1,1"},
  {"iphone2", "iPhone1,2"},
  {"iphone3", "iPhone2,1"},
  {"iphone4", "iPhone3,1"},
  {"iphone4", "iPhone3,3"},
  {"iphone5", "iPhone4,1"},
  {"ipod1", "iPod1,1"},
  {"ipod2", "iPod2,1"},
  {"ipod3", "iPod3,1"},
  {"ipod4", "iPod4,1"},
  {"ipad1", "iPad1,1"},
  {"ipad2", "iPad2,1"},
  {"ipad2", "iPad2,2"},
  {"ipad2", "iPad2,3"},
  {"ipad2", "iPad2,4"},
  {"ipad3", "iPad3,1"},
  {"ipad3", "iPad3,2"},
  {"ipad3", "iPad3,3"},
  {"simulator", "i386"},
  {"simulator", "x86_64"}
};

+ (NSString *)platform {
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);

  char * machine = malloc(size);
  sysctlbyname("hw.machine", machine, &size, NULL, 0);

  NSString * result = nil;
  size_t platforms_size = sizeof(platforms) / sizeof(platforms[0]);
  for (int i = 0; i < platforms_size; i++) {
    if (strcmp(platforms[i].machine, machine) == 0) {
      result = [NSString stringWithUTF8String:platforms[i].code];
      break;
    }
  }

  if (result == nil) {
    result = [NSString stringWithUTF8String:machine];
  }

  free(machine);

  return result;
}

+ (NSString *)carrierName
{
	return [[RJURL subscriberCarrier] carrierName];
}

+ (NSString *)carrierCode
{
	NSMutableString *theResultCode = [NSMutableString string];
	NSString *theMobileCountryCode = [[RJURL subscriberCarrier] mobileCountryCode];
	if ([theMobileCountryCode length] > 0)
	{
		[theResultCode appendFormat:@"%@-", theMobileCountryCode];
	}
	else
	{
		return nil;
	}
	
	NSString *theMobileNetworkCode = [[RJURL subscriberCarrier] mobileNetworkCode];
	if ([theMobileNetworkCode length] > 0)
	{
		[theResultCode appendString:theMobileNetworkCode];
	}
	else
	{
		return nil;
	}
	
	return [NSString stringWithString:theResultCode];
}

+ (CTCarrier *)subscriberCarrier
{
	CTTelephonyNetworkInfo *theNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier *theCarrier = [theNetworkInfo subscriberCellularProvider];
	return theCarrier;
}

+ (NSInteger)lengthForTargetingValue:(NSString *)aValue
{
	return [[aValue stringByReplacingOccurrencesOfString:@" " withString:@""] length];
}

+ (NSString *)parameterForIntegrationType:(RJIntegrationType)aType
{
	static NSDictionary *sParameterNamesMap = nil;
	if (nil == sParameterNamesMap)
	{
		sParameterNamesMap = @{
				@(kRJIntegrationRevJetSDKDirect): @"RevJetSDK",
				@(kRJIntegrationAdMob): @"Admob_RevJetSDK"
		};
	};

	return sParameterNamesMap[@(aType)];
}

@end
