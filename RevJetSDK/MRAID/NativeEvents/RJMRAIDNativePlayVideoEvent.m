//
//  RJMRAIDNativePlayVideoEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativePlayVideoEvent.h"

#import <MediaPlayer/MediaPlayer.h>

@interface RJMRAIDNativePlayVideoEvent ()

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)aNotification;

@end

@implementation RJMRAIDNativePlayVideoEvent

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	NSString *theURLString = [aParameters objectForKey:@"uri"];
	if ([theURLString length] > 0)
	{
		NSURL *theURL = [NSURL URLWithString:theURLString];
		if (nil != theURL)
		{
			UIGraphicsBeginImageContext(CGSizeMake(1,1));
			MPMoviePlayerViewController *theMoviePlayerViewController = [[MPMoviePlayerViewController alloc]
						initWithContentURL:theURL];
			UIGraphicsEndImageContext();
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:)
						name:MPMoviePlayerPlaybackDidFinishNotification object:theMoviePlayerViewController];
			
			[self.delegate nativeEventWillPresentModalView:self];
			[[self.delegate viewControllerForPresentingModalView]
						presentViewController:theMoviePlayerViewController animated:YES completion:nil];
		}
		else
		{
			[self reportErrorWithMessage:@"Video URL is not valid"];
		}
	}
	else
	{
		[self reportErrorWithMessage:@"Missing URL in arguments"];
	}
}

#pragma mark - Notifications

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)aNotification
{
	[self.delegate nativeEventDidDismissModalView:self];
}

@end
