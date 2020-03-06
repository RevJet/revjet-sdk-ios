//
//  RJBaseAdapterInterstitial.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJBaseAdapterInterstitial.h"

#import "RJAdapterDelegate.h"
#import "RJGlobal.h"

@implementation RJBaseAdapterInterstitial

- (void)showAd
{
}

- (void)reportDidFailWithErrorMessage:(NSString *)aMessage code:(NSInteger)aCode
{
  NSDictionary *theInfoDictionary = @{NSLocalizedDescriptionKey: NSLocalizedString(aMessage, @"")};
  NSError *theError = [NSError errorWithDomain:kRJErrorDomain code:aCode userInfo:theInfoDictionary];
  [self.delegate adapter:self didFailToReceiveInterstitialAd:nil error:theError];
}

@end
