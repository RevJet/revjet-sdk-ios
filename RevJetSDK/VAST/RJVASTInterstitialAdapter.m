//
//  RJVASTInterstitialAdapter.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTInterstitialAdapter.h"

#import "RJAdapterDelegate.h"

#import "RJVASTAdRepresentation.h"
#import "RJVASTMediaFileRepresentation.h"
#import "RJVASTCompanionAdRepresentation.h"
#import "RJVASTRepresentationUtilities.h"

#import "RJVASTInterstitialController.h"
#import "RJInterstitialControllerDelegate.h"

#import "RJGlobal.h"

static NSString *const kRJMediaFileCacheName = @"revjet_vast_ad";
static NSString *const kRJCompanionAdCacheName = @"revjet_companion_ad";

@interface RJVASTInterstitialAdapter () <RJInterstitialControllerDelegate>

@property (nonatomic, strong) RJVASTAdRepresentation *adRepresentation;
@property (nonatomic, strong) RJVASTInterstitialController *interstitialAd;

@end

@implementation RJVASTInterstitialAdapter

- (void)dealloc
{
	RJLog(@"dealloc");

	self.interstitialAd.delegate = nil;
	self.interstitialAd = nil;
}

- (void)getAd
{
	RJVASTAdRepresentation *theAdRepresentation = self.params[kRJVASTAdRepresentationKey];
	if (nil == theAdRepresentation)
	{
		[self reportDidFailWithErrorMessage:@"Ad representation is absent" code:404];
		return;
	}
	
	RJVASTMediaFileRepresentation *theBestMediaFile = [RJVASTRepresentationUtilities
				bestMediaFileRepresentation:theAdRepresentation.mediaFiles];
	theAdRepresentation.bestMediaFile = theBestMediaFile;
	RJVASTCompanionAdRepresentation *theBestCompanionAd = [RJVASTRepresentationUtilities
				bestCompanionAdRepresentation:theAdRepresentation.companionAds];
	theAdRepresentation.bestCompanionAd = theBestCompanionAd;
	self.adRepresentation = theAdRepresentation;
	
	NSString *theVideoURL = self.adRepresentation.bestMediaFile.videoURL;
	if (nil == theVideoURL)
	{
		[self reportDidFailWithErrorMessage:@"Video URL is nil" code:404];
		return;
	}
	
	self.interstitialAd = [[RJVASTInterstitialController alloc] initWithDelegate:self
																adRepresentation:self.adRepresentation];
	
	RJLog(@"Downloading media file from URL: %@", theVideoURL);
	[self cacheFileFromURL:theVideoURL withName:kRJMediaFileCacheName handler:^(NSString *aPath)
	{
		if (nil != aPath)
		{
			self.adRepresentation.mediaFilePath = aPath;
			NSString *theImageURL = self.adRepresentation.bestCompanionAd.imageURL;
			if (nil != theImageURL)
			{
				RJLog(@"Downloading companion ad from URL: %@", theImageURL);
				[self cacheFileFromURL:theImageURL withName:kRJCompanionAdCacheName handler:^(NSString *aPath)
				{
					if (nil != aPath)
					{
						self.adRepresentation.companionAdPath = aPath;
					}
					else
					{
						RJLog(@"Could not download companion ad from URL: %@", theImageURL);
					}
					[self.interstitialAd loadAd];
					[self.delegate adapter:self didReceiveInterstitialAd:self.interstitialAd];
				}];
			}
			else
			{
				RJLog(@"Companion ad URL is nil");
			}
		}
		else
		{
			[self reportDidFailWithErrorMessage:[NSString stringWithFormat:
						@"Could not download video from URL: %@", theVideoURL] code:404];
		}
	}];
}

- (void)showAd
{
	[self.delegate adapter:self willPresentInterstitialAd:self.interstitialAd];
	[[self.delegate viewControllerForPresentingModalView]
				presentViewController:self.interstitialAd animated:YES completion:nil];
}

#pragma mark - Private

- (void)cacheFileFromURL:(NSString *)aURL withName:(NSString *)aName
			handler:(void (^) (NSString *aPath))aHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
	{
		NSData *theDownloadedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aURL]];
		if (nil != theDownloadedData)
		{
			NSString *theCacheDirectory = [NSSearchPathForDirectoriesInDomains(
						NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
			NSString *thePath = [theCacheDirectory
						stringByAppendingPathComponent:aName];
			if (nil != [aURL pathExtension])
			{
				thePath = [thePath stringByAppendingPathExtension:[aURL pathExtension]];
			}
			[theDownloadedData writeToFile:thePath atomically:YES];
			dispatch_async(dispatch_get_main_queue(), ^
			{
				aHandler(thePath);
			});
		}
		else
		{
			dispatch_async(dispatch_get_main_queue(), ^
			{
				aHandler(nil);
			});
		}
	});
}

#pragma mark - RJInterstitialControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return [self.delegate viewControllerForPresentingModalView];
}

- (void)didDismissInterstitialController:(RJBaseInterstitialController *)aController
{
	[self.delegate adapter:self didDismissInterstitialAd:self.interstitialAd];
	self.interstitialAd = nil;
}

- (void)applicationWillTerminateFromInterstitialController:(RJBaseInterstitialController *)aController
{
	[self.delegate adapter:self applicationWillTerminateFromInterstitialAd:aController];
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	return [self.delegate adapter:self shouldOpenURL:url];
}

@end
