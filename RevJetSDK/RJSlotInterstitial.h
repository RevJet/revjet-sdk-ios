//
//  RJSlotInterstitial.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJSlot.h"

//! Slot class that represents a place for an entire screen for interstitial ads.
@interface RJSlotInterstitial : RJSlot

//! Initialize the interstitial slot.
//! @param aDelegate RJSlotDelegate delegate (optional)
//! @param aTagUrl Tag/config URL (required)
- (id)initWithDelegate:(id<RJSlotDelegate>)aDelegate tagUrl:(NSString *)aTagUrl;

@end
