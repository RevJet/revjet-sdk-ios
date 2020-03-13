//
//  RJVASTXMLParserAggregator.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTXMLParserAggregator.h"

#import "RJXMLParser.h"
#import "RJVASTAdRepresentation.h"

#import "RJNetwork.h"

static NSInteger const kRJMaxNumberOfWrappers = 20;

@interface RJVASTXMLParserAggregator ()

@property (nonatomic, strong) NSMutableArray *adRepresentations;
@property (nonatomic, assign) NSInteger numberOfParsing;

@end

@implementation RJVASTXMLParserAggregator

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		self.adRepresentations = [NSMutableArray arrayWithCapacity:1];
	}
	return self;
}

#pragma mark -

- (void)parseVASTXML:(NSString *)aXMLString
			withHandler:(void (^) (NSDictionary *aParameters))aHandler
{
	RJXMLParser *theParser = [[RJXMLParser alloc] initWithXMLString:aXMLString];
	[theParser parseWithHandler:^(RJVASTAdRepresentation *anAdRepresentation)
	{
		if (nil != anAdRepresentation)
		{
			[self.adRepresentations addObject:anAdRepresentation];
			
			if (nil != anAdRepresentation.adTagUri && self.numberOfParsing < kRJMaxNumberOfWrappers)
			{
				self.numberOfParsing = self.numberOfParsing + 1;
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
				{
					NSMutableURLRequest *theDownloadRequest = [NSMutableURLRequest
								requestWithURL:[NSURL URLWithString:anAdRepresentation.adTagUri]
								cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
					[theDownloadRequest setValue:kRJUserAgent forHTTPHeaderField:@"User-Agent"];
					NSURLResponse *theResponse = nil;
					NSError *theError = nil;
					NSData *theResponseData = [NSURLConnection sendSynchronousRequest:theDownloadRequest
								returningResponse:&theResponse error:&theError];
					NSString *theXML = nil;
					if (nil != theResponseData)
					{
						theXML = [[NSString alloc] initWithData:theResponseData encoding:NSUTF8StringEncoding];
					}
					
					if ((nil == theError) && ([theXML length] > 0))
					{
						dispatch_async(dispatch_get_main_queue(), ^
						{
							[self parseVASTXML:theXML withHandler:aHandler];
						});
					}
					else
					{
						dispatch_async(dispatch_get_main_queue(), ^
						{
							[self notifyDidEntWithHandler:aHandler];
						});
					}
				});
			}
			else
			{
				[self notifyDidEntWithHandler:aHandler];
			}
		}
	}];
}

#pragma mark - Private

- (void)notifyDidEntWithHandler:(void (^) (NSDictionary *aParameters))aHandler
{
	self.numberOfParsing = 0;
	
	NSMutableDictionary *theParameters = [NSMutableDictionary dictionary];
	if ([self.adRepresentations count] == 1)
	{
		[theParameters setObject:[self.adRepresentations lastObject] forKey:kRJVASTAdRepresentationKey];
	}
	else if ([self.adRepresentations count] > 1)
	{
		RJVASTAdRepresentation *theRepresentation = [self.adRepresentations objectAtIndex:0];
		for (int i = 1; i < [self.adRepresentations count]; ++i)
		{
			RJVASTAdRepresentation *theNext = [self.adRepresentations objectAtIndex:i];
			
			[theRepresentation addImpressions:theNext.impressions];
			if (nil == theRepresentation.clickThrough)
			{
				theRepresentation.clickThrough = theNext.clickThrough;
			}
			[theRepresentation addClickTrackingEvents:theNext.clickTrackingEvents];
			
			[theRepresentation addStartTrackingEvents:theNext.startTrackingEvents];
			[theRepresentation addFirstQuartileTrackingEvents:theNext.firstQuartileTrackingEvents];
			[theRepresentation addMidpointTrackingEvents:theNext.midpointTrackingEvents];
			[theRepresentation addThirdQuartileTrackingEvents:theNext.thirdQuartileTrackingEvents];
			[theRepresentation addCompleteTrackingEvents:theNext.completeTrackingEvents];
			
			[theRepresentation addMediaFiles:theNext.mediaFiles];
			[theRepresentation addCompanionAds:theNext.companionAds];
		}
		
		[theParameters setObject:theRepresentation forKey:kRJVASTAdRepresentationKey];
	}
	
	aHandler(theParameters);
}

@end
