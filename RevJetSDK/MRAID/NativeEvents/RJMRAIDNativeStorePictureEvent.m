//
//  RJMRAIDNativeStorePictureEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJMRAIDNativeStorePictureEvent.h"

@interface RJMRAIDNativeStorePictureEvent () <UIAlertViewDelegate>

@property (nonatomic, strong) NSURL *imageURL;

- (void)performDownloadImageFromURL:(NSURL *)anURL;
- (void)saveImageToLibrary:(UIImage *)anImage;

@end

@implementation RJMRAIDNativeStorePictureEvent

@synthesize imageURL;

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	NSString *theURLString = [aParameters objectForKey:@"uri"];
	if ([theURLString length] > 0)
	{
		NSURL *theURL = [NSURL URLWithString:theURLString];
		if (nil != theURL)
		{
			[self.delegate nativeEventWillPresentModalView:self];
			self.imageURL = theURL;
			UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle:nil message:
						@"Save this image to your photo library?" delegate:self
						cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save Image", nil];
			[theAlertView show];
		}
		else
		{
			[self reportErrorWithMessage:@"Image URL is not valid"];
		}
	}
	else
	{
		[self reportErrorWithMessage:@"Missing URL in arguments"];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex
{
	[self.delegate nativeEventDidDismissModalView:self];
	if (aButtonIndex == anAlertView.cancelButtonIndex)
	{
		[self reportErrorWithMessage:@"The user canceled the action."];
	}
	else if (aButtonIndex == anAlertView.firstOtherButtonIndex)
	{
		[self performSelectorInBackground:@selector(performDownloadImageFromURL:) withObject:self.imageURL];
	}
}

#pragma mark - Private

- (void)performDownloadImageFromURL:(NSURL *)anURL
{
	@autoreleasepool
	{
		if (nil != anURL)
		{
			NSData *theImageData = [NSData dataWithContentsOfURL:anURL];
			if (nil != theImageData)
			{
				UIImage *theImage = [UIImage imageWithData:theImageData];
				[self performSelectorOnMainThread:@selector(saveImageToLibrary:) withObject:theImage waitUntilDone:NO];
			}
		}
	}
}

- (void)saveImageToLibrary:(UIImage *)anImage
{
	UIImageWriteToSavedPhotosAlbum(anImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark -

- (void)image:(UIImage *)anImage didFinishSavingWithError:(NSError *)anError contextInfo:(void *)aContextInfo
{
	if (nil != anError)
	{
		[self reportErrorWithMessage:[anError description]];
	}
}

@end
