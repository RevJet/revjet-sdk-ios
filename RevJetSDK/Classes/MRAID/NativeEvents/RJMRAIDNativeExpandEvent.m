//
//  RJMRAIDNativeExpandEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeExpandEvent.h"

#import "RJGlobal.h"

#import "RJMRAIDView.h"
#import "RJMRAIDViewDelegate.h"
#import "RJNetwork.h"

@interface RJMRAIDNativeExpandEvent ()

- (void)loadURLAndExpand:(NSDictionary *)aParameters;
- (void)expandWithContent:(NSDictionary *)aParameters;

@end

@implementation RJMRAIDNativeExpandEvent

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	RJMRAIDView *theMRAIDView = [self.delegate MRAIDView];
	if (kRJMRAIDPlacementTypeInterstitial == theMRAIDView.placementType)
	{
		[self reportErrorWithMessage:@"Can't expand interstitial ad"];
		return;
	}

	CGSize theNewSize = CGSizeMake([[aParameters objectForKey:@"width"] floatValue],
				[[aParameters objectForKey:@"height"] floatValue]);

	NSString *theUseCustomClose = [aParameters objectForKey:@"shouldUseCustomClose"];
	if ([theUseCustomClose isEqualToString:@"true"])
	{
		[self.delegate nativeEvent:self willUseCutomCloseButton:YES];
	}
	else if ([theUseCustomClose isEqualToString:@"false"])
	{
		[self.delegate nativeEvent:self willUseCutomCloseButton:NO];
	}

	if ([theMRAIDView.delegate respondsToSelector:@selector(willExpand)])
	{
		[theMRAIDView.delegate willExpand];
	}

	NSString *theURL = [aParameters objectForKey:@"url"];
	if (0 == [theURL length])
	{
		[theMRAIDView expandToSize:theNewSize withContent:nil];
	}
	else
	{
		// Load Ad from the URL and show it in a seperate UIWebView
		[self performSelectorInBackground:@selector(loadURLAndExpand:) withObject:
					[NSDictionary dictionaryWithObjectsAndKeys:theURL, @"url",
					[NSValue valueWithCGSize:theNewSize], @"size", nil]];
	}
}

#pragma mark - Private

// Runs on background thread
- (void)loadURLAndExpand:(NSDictionary *)aParameters
{
	@autoreleasepool
	{
		RJLog(@"loadURLAndExpand:");
		
		NSURL *theURL = [NSURL URLWithString:[aParameters objectForKey:@"url"]];
		
		NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
					cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
		[theRequest setValue:kRJUserAgent forHTTPHeaderField:@"User-Agent"];
	
		NSURLResponse *theResponse = nil;
		NSData *theResponseDate = [NSURLConnection sendSynchronousRequest:theRequest
					returningResponse:&theResponse error:NULL];
		if (nil != theResponseDate)
		{
			NSString *theHTMLContent = [[NSString alloc] initWithData:theResponseDate encoding:NSUTF8StringEncoding];
			[self performSelectorOnMainThread:@selector(expandWithContent:)
						withObject:@{@"content": theHTMLContent, @"size": aParameters[@"size"]} waitUntilDone:YES];
    }
  }
}

// Runs on main thread
- (void)expandWithContent:(NSDictionary *)aParameters
{
	NSString *theContent = [aParameters objectForKey:@"content"];
	NSValue *theNewSize = [aParameters objectForKey:@"size"];
	[[self.delegate MRAIDView] expandToSize:[theNewSize CGSizeValue] withContent:theContent];
}


@end
