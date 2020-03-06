//
//  RJUtilities.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJUtilities : NSObject

+ (UIButton *)closeButton;

+ (BOOL)isiPad;

+ (void)disableJavaScriptDialogsForWebView:(UIWebView *)aView;

+ (BOOL)isLandscapeSupported;

+ (NSInteger)iTunesIDForRequestURL:(NSURL *)aRequestURL;

+ (NSDictionary *)getParametersFromSlotTag:(NSString *)aSlotTag;

+ (BOOL)isSmartBanner:(NSString *)aSlotId;
+ (CGSize)supportedSizeForSize:(CGSize)aSize;
+ (NSString *)stringForSize:(CGSize)aSize;
+ (NSString *)stringEscapedForJavaScript:(NSString *)str;

@end
