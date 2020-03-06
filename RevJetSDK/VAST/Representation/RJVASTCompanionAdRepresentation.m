//
//  RJVASTCompanionAdRepresentation.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTCompanionAdRepresentation.h"

static NSString *const kRJCompanionAdURL = @"CompanionAdURL";
static NSString *const kRJClickThrough = @"CompanionClickThrough";
static NSString *const kRJTrackingEvents = @"TrackingEvents";
static NSString *const kRJTrackingEventURL = @"URL";

static NSString *const kRJCreativeType = @"creativeType";

@implementation RJVASTCompanionAdRepresentation

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	self = [super initWithDictionary:aDictionary];
	if (nil != self)
	{
		self.imageURL = [aDictionary objectForKey:kRJCompanionAdURL];
		self.clickThroughURL = [aDictionary objectForKey:kRJClickThrough];
		[self processTrackingEvents:[aDictionary objectForKey:kRJTrackingEvents]];
		
		
		if (nil == self.type)
		{
			self.type = [aDictionary objectForKey:kRJCreativeType];
		}
	}
	return self;
}

#pragma mark - Private

- (void)processTrackingEvents:(NSArray *)anEvents
{
	if ([anEvents count] > 0)
	{
		self.clickTrackers = [NSMutableArray array];
		for (NSDictionary *theInfo in anEvents)
		{
			NSString *theURL = [theInfo objectForKey:kRJTrackingEventURL];
			if (nil != theURL)
			{
				[self.clickTrackers addObject:theURL];
			}
		}
	}
}

@end
