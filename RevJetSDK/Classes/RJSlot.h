//
//  RJSlot.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJSlotViewDelegate.h"

// A version of RevJet SDK
OBJC_EXTERN NSString *const kRJSDKVersion;

//! A versions of MRAID ADs.
OBJC_EXTERN NSString *const kRJMRAIDVersion;

@class RJNetwork, RJSlotView;
@protocol RJSlotDelegate;

//! Slot class that represents a place for a banner view.
@interface RJSlot : NSObject<RJSlotViewDelegate>

//! Ads will be shown inside this view.
@property (nonatomic, readonly) RJSlotView *view;

//! Set this delegate if you wish to be informed about certain events such as:
//! an ad has been received, an error occurred and so on. Also, you can improve
//! quality of the ads if you set targeting information to this delegate.
@property (nonatomic, unsafe_unretained) id<RJSlotDelegate> delegate;

//! An object that holds business-related logic.
@property (nonatomic, strong) RJNetwork *network;

//! Tag/config URL.
@property (nonatomic, readonly) NSString *tagUrl;

//! Automatically reload the slot after some period of time. Each ad can have
//! its own display duration. By default |autoRefresh| set to NO.
@property (nonatomic, assign) BOOL autoRefresh;

//! Use this property for showing close button on banner AD or interstitial. Default value for banner is <code>NO</code.
//! Default value for interstitial is <code>YES</code>.
@property (nonatomic, strong) NSNumber *showCloseButton;

//! Initialize the slot.
//! @param aDelegate RJSlotDelegate delegate (optional)
//! @param aTagUrl Tag/config URL (required)
//! @aFrame Position and size (required)
- (id)initWithDelegate:(id<RJSlotDelegate>)aDelegate tagUrl:(NSString *)aTagUrl frame:(CGRect)aFrame;

//! Loads and show the slot. Call this method after you initialize the slot.
- (void)loadAd;

//! Fetchs slot without showing it.
- (void)fetchAd;

//! Shows slot if it was previously fetched.
- (void)showAd;

//! Pause/continue refreshing process. Recommend to call these methods on viewWillAppear/viewWillDisappear
- (void)pauseAd;
- (void)resumeAd;

//! Add |RJSlotView| to the |view| where you want to display ads.
- (void)addToView:(UIView *)aView;

@end
