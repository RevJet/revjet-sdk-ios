//
//  RJNetworkMapping.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJNetworkMapping.h"
#import "RJBaseAdapter.h"

#import "RJAdapter.h"
#import "RJAdapterInterstitial.h"

NSString *const kRJNetworkType = @"RJ";
NSString *const kRJ2NetworkType = @"REVJET2";
NSString *const kRJAdMobNetworkType = @"ADMOB";
NSString *const kRJIAdNetworkType = @"IAD";
NSString *const kRJMillennialMediaNetworkType = @"MILLENNIALMEDIA";
NSString *const kRJCustomNetworkType = @"CUSTOM";
NSString *const kRJJumptapNetworkType = @"JUMPTAP";
NSString *const kRJGreystripeNetworkType = @"GREYSTRIPE";
NSString *const kRJInMobiNetworkType = @"INMOBI";
NSString *const kRJMRAIDNetworkType = @"MRAID";
NSString *const kRJVASTNetworkType = @"VAST";
NSString *const kRJMobclixNetworkType = @"MOBCLIX";
NSString *const kRJMoPubNetworkType = @"MOPUB";
NSString *const kRJMobFoxNetworkType = @"MOBFOX";

NSString *const kRJNetworkSlotTagKey = @"SLOTTAG";
NSString *const kRJMillennialMediaAppIDKey = @"APID";
NSString *const kRJInMobiAppIDKey = @"APPID";
NSString *const kRJGreystripeAppIDKey = @"APPID";
NSString *const kRJAdMobAppIDKey = @"ADUNITID";
NSString *const kRJMobclixAppIDKey = @"ADUNITID";
NSString *const kRJJumptapAppIDKey = @"PUBLISHERID";
NSString *const kRJJumptapSiteIDKey = @"SITE";
NSString *const kRJJumptapAdspotIDKey = @"ADSPOT";
NSString *const kRJMoPubAppIDKey = @"ADUNITID";
NSString *const kRJMobFoxAppIDKey = @"PUBLISHERID";

NSString *const kRJAdTypeBanner = @"BANNER";
NSString *const kRJAdTypeInterstitial = @"INTERSTITIAL";

static NSString *const kRJParamNetworkType = @"NetworkType";

static RJNetworkMapping *sNetworkMapping = nil;

@interface RJNetworkMapping ()

@property (nonatomic, strong) NSDictionary *mapping;
@property (nonatomic, strong) NSDictionary *interstitialMapping;

- (Class)adapderClassForType:(NSString *)aType mapping:(NSDictionary *)aMapping;

@end

@implementation RJNetworkMapping

@synthesize mapping = mapping_,
			interstitialMapping = interstitialMapping_;

+ (RJNetworkMapping *)sharedMapping
{
	@synchronized(self)
	{
		if (nil == sNetworkMapping)
		{
			sNetworkMapping = [[self alloc] init];
		}
	}
	
	return sNetworkMapping;
}

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		mapping_ = @{
				kRJ2NetworkType: @"RJAdapter",
				kRJAdMobNetworkType: @"RJAdMobAdapter",
				kRJCustomNetworkType: @"RJCustomEventAdapter",
				kRJIAdNetworkType: @"RJIAdAdapter",
				kRJMillennialMediaNetworkType: @"RJMillennialMediaAdapter",
				kRJJumptapNetworkType: @"RJJumptapAdapter",
				kRJGreystripeNetworkType: @"RJGreystripeAdapter",
				kRJInMobiNetworkType: @"RJInMobiAdapter",
				kRJMRAIDNetworkType: @"RJMRAIDAdapter",
				kRJMobclixNetworkType: @"RJMobclixAdapter",
				kRJMoPubNetworkType: @"RJMopubAdapter",
				kRJMobFoxNetworkType: @"RJMobFoxAdapter"
		};

		interstitialMapping_ = @{
				kRJ2NetworkType: @"RJAdapterInterstitial",
				kRJCustomNetworkType: @"RJCustomEventAdapter",
				kRJAdMobNetworkType: @"RJAdMobInterstitialAdapter",
				kRJIAdNetworkType: @"RJIAdInterstitialAdapter",
				kRJMillennialMediaNetworkType: @"RJMillennialMediaInterstitialAdapter",
				kRJJumptapNetworkType: @"RJJumptapInterstitialAdapter",
				kRJGreystripeNetworkType: @"RJGreystripeInterstitialAdapter",
				kRJInMobiNetworkType: @"RJInMobiInterstitialAdapter",
				kRJMRAIDNetworkType: @"RJMRAIDInterstitialAdapter",
				kRJVASTNetworkType: @"RJVASTInterstitialAdapter",
				kRJMobclixNetworkType: @"RJMobclixInterstitialAdapter",
				kRJMoPubNetworkType: @"RJMopubInterstitialAdapter"
		};
	}
	
	return self;
}


#pragma mark -

- (Class)adapterClassForType:(NSString *)aType
{
	if ([kRJNetworkType isEqual:aType])
	{
		return [RJAdapter class];
	}
	
	return [self adapderClassForType:aType mapping:self.mapping];
}

- (Class)interstitialAdapterClassForType:(NSString *)aType
{
	if ([kRJNetworkType isEqual:aType])
	{
		return [RJAdapterInterstitial class];
	}

	return [self adapderClassForType:aType mapping:self.interstitialMapping];
}

#pragma mark - Private

- (Class)adapderClassForType:(NSString *)aType mapping:(NSDictionary *)aMapping
{
	NSString *theAdapterClassName = [aMapping objectForKey:aType];
	if (nil == theAdapterClassName)
	{
		return nil;
	}

	Class theResultAdapter = NSClassFromString(theAdapterClassName);
	if (![theResultAdapter isSubclassOfClass:[RJBaseAdapter class]])
	{
		return nil;
	}
	
	return theResultAdapter;
}

@end
