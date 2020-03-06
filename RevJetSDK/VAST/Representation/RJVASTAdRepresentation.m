//
//  RJVASTAdRepresentation.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTAdRepresentation.h"

#import "RJVASTMediaFileRepresentation.h"
#import "RJVASTCompanionAdRepresentation.h"

NSString *const kRJVASTAdRepresentationKey = @"RJVASTAdRepresentation";

@implementation RJVASTAdRepresentation

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (nil == aDictionary)
	{
		return nil;
	}
	
	self = [super init];
	if (nil != self)
	{
		self.adTagUri = [aDictionary objectForKey:@"VASTAdTagURI"];
		
		[self addImpressions:[aDictionary objectForKey:@"Impression"]];
		self.clickThrough = [[aDictionary objectForKey:@"ClickThrough"] objectAtIndex:0];
		[self addClickTrackingEvents:[aDictionary objectForKey:@"ClickTracking"]];
		
		[self processTrackingEvents:[aDictionary objectForKey:@"TrackingEvents"]];
		
		NSArray *theMediaFilesInfo = [aDictionary objectForKey:@"MediaFiles"];
		[self processMediaFilesFromInfo:theMediaFilesInfo];
		
		NSArray *theCompanionAdsInfo = [aDictionary objectForKey:@"CompanionAds"];
		[self processCompanionAdsFromInfo:theCompanionAdsInfo];
	}
	return self;
}

- (id)init
{
	return [self initWithDictionary:nil];
}

#pragma mark -

- (void)addImpressions:(NSArray *)anImpressions
{
	if ([anImpressions count] > 0)
	{
		if (nil == self.impressions)
		{
			self.impressions = [NSMutableArray array];
		}
		[self.impressions addObjectsFromArray:anImpressions];
	}
}

- (void)addClickTrackingEvents:(NSArray *)anEvents
{
	if ([anEvents count] > 0)
	{
		if (nil == self.clickTrackingEvents)
		{
			self.clickTrackingEvents = [NSMutableArray array];
		}
		[self.clickTrackingEvents addObjectsFromArray:anEvents];
	}
}

- (void)addStartTrackingEvents:(NSArray *)anEvents
{
	if ([anEvents count] > 0)
	{
		if (nil == self.startTrackingEvents)
		{
			self.startTrackingEvents = [NSMutableArray array];
		}
		[self.startTrackingEvents addObjectsFromArray:anEvents];
	}
}

- (void)addFirstQuartileTrackingEvents:(NSArray *)anEvents
{
	if ([anEvents count] > 0)
	{
		if (nil == self.firstQuartileTrackingEvents)
		{
			self.firstQuartileTrackingEvents = [NSMutableArray array];
		}
		[self.firstQuartileTrackingEvents addObjectsFromArray:anEvents];
	}
}

- (void)addMidpointTrackingEvents:(NSArray *)anEvents
{
	if ([anEvents count] > 0)
	{
		if (nil == self.midpointTrackingEvents)
		{
			self.midpointTrackingEvents = [NSMutableArray array];
		}
		[self.midpointTrackingEvents addObjectsFromArray:anEvents];
	}
}

- (void)addThirdQuartileTrackingEvents:(NSArray *)anEvents
{
	if ([anEvents count] > 0)
	{
		if (nil == self.thirdQuartileTrackingEvents)
		{
			self.thirdQuartileTrackingEvents = [NSMutableArray array];
		}
		[self.thirdQuartileTrackingEvents addObjectsFromArray:anEvents];
	}
}
- (void)addCompleteTrackingEvents:(NSArray *)anEvents
{
	if ([anEvents count] > 0)
	{
		if (nil == self.completeTrackingEvents)
		{
			self.completeTrackingEvents = [NSMutableArray array];
		}
		[self.completeTrackingEvents addObjectsFromArray:anEvents];
	}
}

- (void)addMediaFiles:(NSArray *)aMediaFiles
{
	if ([aMediaFiles count] > 0)
	{
		if (nil == self.mediaFiles)
		{
			self.mediaFiles = [NSMutableArray array];
		}
		[self.mediaFiles addObjectsFromArray:aMediaFiles];
	}
}

- (void)addCompanionAds:(NSArray *)aCompanionAds
{
	if ([aCompanionAds count] > 0)
	{
		if (nil == self.companionAds)
		{
			self.companionAds = [NSMutableArray array];
		}
		[self.companionAds addObjectsFromArray:aCompanionAds];
	}
}

#pragma mark - Private

- (void)processMediaFilesFromInfo:(NSArray *)anInfo
{
	NSMutableArray *theMediaFiles = [NSMutableArray arrayWithCapacity:[anInfo count]];
	for (NSDictionary *theInfo in anInfo)
	{
		RJVASTMediaFileRepresentation *theMediaFile = [[RJVASTMediaFileRepresentation alloc]
					initWithDictionary:theInfo];
		if (nil != theMediaFile)
		{
			[theMediaFiles addObject:theMediaFile];
		}
	}
	self.mediaFiles = [NSMutableArray arrayWithArray:theMediaFiles];
}

- (void)processCompanionAdsFromInfo:(NSArray *)anInfo
{
	NSMutableArray *theCompanionAds = [NSMutableArray arrayWithCapacity:[anInfo count]];
	for (NSDictionary *theInfo in anInfo)
	{
		RJVASTCompanionAdRepresentation *theCompanionAd = [[RJVASTCompanionAdRepresentation alloc]
					initWithDictionary:theInfo];
		if (nil != theCompanionAd)
		{
			[theCompanionAds addObject:theCompanionAd];
		}
	}
	self.companionAds = [NSMutableArray arrayWithArray:theCompanionAds];
}

- (void)processTrackingEvents:(NSArray *)anEvents
{
	self.startTrackingEvents = [NSMutableArray array];
	self.firstQuartileTrackingEvents = [NSMutableArray array];
	self.midpointTrackingEvents = [NSMutableArray array];
	self.thirdQuartileTrackingEvents = [NSMutableArray array];
	self.completeTrackingEvents = [NSMutableArray array];
	
	for (NSDictionary *theInfo in anEvents)
	{
		NSString *theEventType = [theInfo objectForKey:@"event"];
		NSString *theURL = [theInfo objectForKey:@"URL"];
		if (nil != theEventType && nil != theURL)
		{
			if ([theEventType isEqualToString:@"start"])
			{
				[self.startTrackingEvents addObject:theURL];
			}
			else if ([theEventType isEqualToString:@"firstQuartile"])
			{
				[self.firstQuartileTrackingEvents addObject:theURL];
			}
			else if ([theEventType isEqualToString:@"midpoint"])
			{
				[self.midpointTrackingEvents addObject:theURL];
			}
			else if ([theEventType isEqualToString:@"thirdQuartile"])
			{
				[self.thirdQuartileTrackingEvents addObject:theURL];
			}
			else if ([theEventType isEqualToString:@"complete"])
			{
				[self.completeTrackingEvents addObject:theURL];
			}
		}
	}
}

@end
