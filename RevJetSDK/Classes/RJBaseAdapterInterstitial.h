//
//  RJBaseAdapterInterstitial.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJBaseAdapter.h"

//! A base adapter for interstitial ads.
@interface RJBaseAdapterInterstitial : RJBaseAdapter

//! Shows interstitial ad on the view controller which is returned
//! by <code>viewControllerForPresentingModalView</code> method. You should override this method when subclassin.
//! @see RJAdapterDelegate for more info about delegate method.
- (void)showAd;

- (void)reportDidFailWithErrorMessage:(NSString *)aMessage code:(NSInteger)aCode;

@end
