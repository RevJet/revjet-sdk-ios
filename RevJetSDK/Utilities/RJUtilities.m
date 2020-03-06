//
//  RJUtilities.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJUtilities.h"

static NSString *const kRJiTunesDomain = @"itunes.apple.com";
static NSString *const kRJiTunesIDString = @"id";
static NSInteger const kRJNoiTunesIDValue = 0;
static NSInteger const kRJiTunesIDLength = 9;

static const CGSize kRJAdSize_320x50 = {320, 50};
static const CGSize kRJAdSize_320x64 = {320, 64};
static const CGSize kRJAdSize_320x480 = {320, 480};
static const CGSize kRJAdSize_480x320 = {480, 320};
static const CGSize kRJAdSize_300x250 = {300, 250};
static const CGSize kRJAdSize_728x90 = {728, 90};
static const CGSize kRJAdSize_768x1024 = {768, 1024};
static const CGSize kRJAdSize_1024x768 = {1024, 768};

@interface RJUtilities ()

+ (UIImage *)closeButtonImage;

@end

static CGSize const kRJCloseButtonSize = {28.0f, 28.0f};
static CGSize const kRJCloseButtonSizeiPad = {36.0f, 36.0f};

static NSString *const kRJCloseButtonBase64 = @"data:image/jpg;base64,"
"iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAFT0lEQVR42u2bS0gjSRjH8zDjG112Ljvusicvw467WefiYUBGGITF"
"g6+Dgi4e9CYiiFfPc9i5Dbiw7lE8yF40B0Fw8CQeRCQE9aDgENb1lfgaNaZg6x9SoVLp7vTLrmSoPxT4SHdV/7q+r77vq4rPp6Sk"
"pKSkpKSkpKSkpFSO8hu0gEYLZpsTBYr06y9bmPPz888vLy8HHx8fo8SCrq+v/1lYWPg5C+erU2Bvb+8Nfc4YcSgK9jQWi/1mE1Tp"
"zaytra2X6XR6l7is1GPq887OzqtSBGSqk9bW1hB9239qPlwqRVZXV8nY2Bjp6Oggzc3NpLGxkQSDwUzDz/gb/ofP4LO4RksU/sf2"
"9vaKsgK0vr7+Hd6w+DDUNMj4+DhpaGgg9GOWGq7BtbiHhtntU4jfmnTucgEdHx//hEnCP8D+/j6ZmJiwDEWv4V64pzgx4/H4ryUN"
"6Orq6o046tnZWVJfX+8aHNZwT9xbVDKZfFuSgLIzJ6e7uzsyOTnpOhixoQ/0xev09LRLZ+xBKYDgc3izur29JUNDQ08OhzX0hT55"
"bW9vh2VGznmrFe+Q8Ta9hMNDEmZSam5u7oWUoI//RVzKvTArI3MTVrd/+/v7n0kDhCBQdMhGD1BZWekYQrF7iI6bRvB/yQIU4CNk"
"LLtGqxUCv8PDQ9LX12cbTmdnJzk6OiItLS2Gq5sYAszMzLz0HFA2t8rJKM4BHBqj5HyUWUh+v5+EQiFSXV1Nenp6co747OyMtLW1"
"ZWCwVldXl2m1tbVkeno6D9D5+fmul3lYptTAJ56Ibo1MAm9dDAGMIAEKHpY9fG9vb8EqBUhNTU0FgBik3d389C8SibzybAqhZMF3"
"jhTAaCYAhphLaUEKBAJ5YDBzurq6yM3NTUFAODIyYtgnxsRraWlp0TNAqOfwiaeZ3KoYpKqqqhwY5ojhc+zAYbkb3x9moGeA+GIX"
"Mm2zTlYP0uDgYAYMTAN+xykc1jA2Xp4B4jtFOcLKSqQF6f7+ngwMDOStVk7hoGFs0gGhZmN1uTYyN7fgoGFs0gFhCbcT09AItwDS"
"w8NDQeJpFw4LL6QDQvXPzuBramoyvkevUugUDhrGJh0QSqRWB45r4JAR78CsqNPXhDM8POwoLUE/ZQmIBXTMIWuZFczNSVpSMoDs"
"mBgLAvUcstmIuyxMzKqTxlsFIL0IWTQ3J5BKwklbXeYRJSO30oIDn2M2LSmbZd5qoNjd3V2QeIoO2S1IQqCYkgLISqoBn1MMjpuQ"
"+FSDmu4fngGi5vG31WRVzyEbLeVOIInJ6snJSbNngBYXF19bKXfYgeMUklju8GrLB6pCZ7TPL3YLZlaDQC1IFxcXhiVefos6nU5/"
"8rLk+ixbcv3dbMk1HA5jMy/32dHRUUcJLmYjSq5GW9O8NjY2vvcSUAV3euPKbNGeQQIc5GF24hpAwswxgiMW7ekYP3u9q5Gz5Wg0"
"+tbKtg8GDzjIw5zsyVvZ9llbW3suDRCK93TaL1nZOAQclod5sHH4QfrOKh1UNR1LwuzWMyvKe7D1/J9P0pG7giMkm5ubP/AjMzq8"
"wArzT314YWVlpVbW4QXNMzbxeDxs5vgLX+rwPdHxl4ODgx99EuU3iLDfFTtA5RYgvQNUiUTiF59kGdq1OJPEI3huOGmdI3jSZ44p"
"QJxPSmgd4pyamspsGftcPMRJFZfpcywDYqubGAI8xTFgupS/95XYAXErg/EjmOQjbhcVW15e/sb3NQhpSTZ3++IGGK9zK0+j8Egk"
"8pqvJ5n8fkY0mUy+o+YWKrcHLvYVKPbVpwpWBVBSUlJSUlJSUlJSUlJSKqb/Aa0gmIZLAy0TAAAAAElFTkSuQmCC";

static NSString *const kRJDisableJavaScriptDialogs =
			@"window.alert = function() { }; window.prompt = function() { }; window.confirm = function() { };";

@implementation RJUtilities

+ (UIButton *)closeButton
{
	CGSize theSize = kRJCloseButtonSize;
	if ([RJUtilities isiPad])
	{
		theSize = kRJCloseButtonSizeiPad;
	}
	UIImage *theCloseImage = [RJUtilities closeButtonImage];
	
	UIButton *theResultButton = [UIButton buttonWithType:UIButtonTypeCustom];
	theResultButton.frame = CGRectMake(0.0f, 0.0f, theSize.width, theSize.height);
	[theResultButton setImage:theCloseImage forState:UIControlStateNormal];
	
	return theResultButton;
}

+ (BOOL)isiPad
{
	return (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM());
}

+ (void)disableJavaScriptDialogsForWebView:(UIWebView *)aView
{
	[aView stringByEvaluatingJavaScriptFromString:kRJDisableJavaScriptDialogs];
}

+ (BOOL)isLandscapeSupported
{
	NSArray *theSupportedOrientations = [[NSBundle mainBundle] infoDictionary][@"UISupportedInterfaceOrientations"];
	return [theSupportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"] ||
				[theSupportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"];
}

+ (NSInteger)iTunesIDForRequestURL:(NSURL *)aRequestURL
{
	NSInteger theiTunesID = 0;
	NSString *theHost = [aRequestURL host];
	if ([theHost hasSuffix:kRJiTunesDomain])
	{
		Class theSKProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
		if (Nil != theSKProductViewControllerClass)
		{
			NSArray *thePathComponents = [aRequestURL pathComponents];
			for (NSString *thePathComponent in thePathComponents)
			{
				if ([thePathComponent hasPrefix:kRJiTunesIDString])
				{
					NSString *theStringID = [thePathComponent stringByReplacingOccurrencesOfString:kRJiTunesIDString
								withString:[NSString string]];
					NSInteger theID = [theStringID integerValue];
					if ((kRJNoiTunesIDValue != theID) && (kRJiTunesIDLength == [theStringID length]))
					{
						theiTunesID = theID;
						break;
					}
				}
			}
				
		}
	}
	
	return theiTunesID;
}

+ (NSDictionary *)getParametersFromSlotTag:(NSString *)aSlotTag
{
	NSMutableDictionary *theParameters = [NSMutableDictionary dictionary];
	
	NSArray *theSlotTagComponents = [aSlotTag componentsSeparatedByString:@"?"];
	if ([theSlotTagComponents count] < 2)
	{
		return theParameters;
	}
	
	NSArray *thePathComponents = [theSlotTagComponents[1] componentsSeparatedByString:@"&"];
	for (NSString *theComponent in thePathComponents)
	{
		NSArray *theSubComponents = [theComponent componentsSeparatedByString:@"="];
		if ([theSubComponents count] > 1)
		{
			NSString *theKey = theSubComponents[0];
			NSString *theValue = theSubComponents[1];
			if ([theKey isEqualToString:@"ad_size"])
			{
				NSArray *theValueComponents = [theValue componentsSeparatedByString:@"x"];
				if ([theValueComponents count] > 1)
				{
					NSString *theWidth = theValueComponents[0];
					NSString *theHeight = theValueComponents[1];
					double theWidthValue = [theWidth doubleValue];
					double theHeightValue = [theHeight doubleValue];
					if (theWidthValue > 0 && theHeightValue > 0)
					{
						theParameters[@"WIDTH"] = theWidth;
						theParameters[@"HEIGHT"] = theHeight;
					}
				}
			}
		}
	}
	return [NSDictionary dictionaryWithDictionary:theParameters];
}

+ (BOOL)isSmartBanner:(NSString *)aSlotId
{
	return (NSNotFound != [aSlotId rangeOfString:@"exact_match=1"].location);
}

+ (CGSize)supportedSizeForSize:(CGSize)aSize
{
	CGFloat theWidth = aSize.width;
	CGFloat theHeight = aSize.height;
	CGSize theResult = kRJAdSize_320x50;
	if (theWidth >= 1024 && theHeight >= 768)
	{
		theResult = kRJAdSize_1024x768;
	}
	else if (theWidth >= 768 && theHeight >= 1024)
	{
		theResult = kRJAdSize_768x1024;
	}
	else if (theWidth >= 728 && theHeight >= 90)
	{
		theResult = kRJAdSize_728x90;
	}
	else if (theWidth >= 480 && theHeight >= 320)
	{
		theResult = kRJAdSize_480x320;
	}
	else if (theWidth >= 320 && theHeight >= 480)
	{
		theResult = kRJAdSize_320x480;
	}
	else if (theWidth >= 300 && theHeight >= 250)
	{
		theResult = kRJAdSize_300x250;
	} else if (theWidth >= 320 && theHeight >= 64) {
		theResult = kRJAdSize_320x64;
	}
	return theResult;
}

+ (NSString *)stringForSize:(CGSize)aSize
{
	return [NSString stringWithFormat:@"%dx%d", (int)aSize.width, (int)aSize.height];
}

+ (NSString *)stringEscapedForJavaScript:(NSString *)str {
	NSData* data = [NSJSONSerialization dataWithJSONObject:@[str] options:0 error:nil];
	NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString* escapedString = [jsonString substringWithRange:NSMakeRange(2, jsonString.length - 4)];

	return escapedString;
}

#pragma mark - Private

+ (UIImage *)closeButtonImage
{
	NSData *theImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kRJCloseButtonBase64]];
	UIImage *theCloseButtonImage = [UIImage imageWithData:theImageData];
	return theCloseButtonImage;
}

@end
