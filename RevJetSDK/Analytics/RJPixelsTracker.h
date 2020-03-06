//
//  RJPixelsTracker.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	kRJPixelsTrackerURLImpression,
	kRJPixelsTrackerURLClick,
	kRJPixelsTrackerURLNoBid
} RJPixelsTrackerURLType;

@interface RJPixelsTracker : NSObject

- (id)initWithNetworkInfo:(NSDictionary *)aNetworkInfo;

- (void)trackPixelOfURLType:(RJPixelsTrackerURLType)aType;

@end
