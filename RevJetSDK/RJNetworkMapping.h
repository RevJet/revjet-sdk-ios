//
//  RJNetworkMapping.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kRJNetworkType;
extern NSString *const kRJ2NetworkType;
extern NSString *const kRJAdMobNetworkType;
extern NSString *const kRJIAdNetworkType;
extern NSString *const kRJMillennialMediaNetworkType;
extern NSString *const kRJCustomNetworkType;
extern NSString *const kRJJumptapNetworkType;
extern NSString *const kRJGreystripeNetworkType;
extern NSString *const kRJInMobiNetworkType;
extern NSString *const kRJMRAIDNetworkType;
extern NSString *const kRJVASTNetworkType;
extern NSString *const kRJMobclixNetworkType;
extern NSString *const kRJMoPubNetworkType;
extern NSString *const kRJMobFoxNetworkType;

extern NSString *const kRJNetworkSlotTagKey;
extern NSString *const kRJMillennialMediaAppIDKey;
extern NSString *const kRJInMobiAppIDKey;
extern NSString *const kRJGreystripeAppIDKey;
extern NSString *const kRJAdMobAppIDKey;
extern NSString *const kRJMobclixAppIDKey;
extern NSString *const kRJJumptapAppIDKey;
extern NSString *const kRJJumptapSiteIDKey;
extern NSString *const kRJJumptapAdspotIDKey;
extern NSString *const kRJMoPubAppIDKey;
extern NSString *const kRJMobFoxAppIDKey;

extern NSString *const kRJAdTypeBanner;
extern NSString *const kRJAdTypeInterstitial;

@interface RJNetworkMapping : NSObject

+ (RJNetworkMapping *)sharedMapping;

//! Returns a class for adapter with specified type.
//! @param aType A type of adapter. If type is not recognized - returns <code>nil</code>
- (Class)adapterClassForType:(NSString *)aType;

//! Returns a class for interstitial adapter with specified type.
//! @param aType A type of interstitial adapter. If type is not recognized - returns <code>nil</code>
- (Class)interstitialAdapterClassForType:(NSString *)aType;

@end
