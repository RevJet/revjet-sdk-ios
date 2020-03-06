//
//  RJSlotView.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

OBJC_EXPORT NSString * const kRJDefaultTransitionAnimation;

@protocol RJSlotViewDelegate;

//! Represents an integration type of SDK.
typedef enum
{
	//! A publisher integrates AdMob Mediation SDK and use RevJetSDK adapter to integrate our SDK.
	kRJIntegrationAdMob,
	
	//! A publisher deals with our SDK directly and integrate it in his application.
	kRJIntegrationRevJetSDKDirect
} RJIntegrationType;

@interface RJSlotView : UIView

//! Initializes with delegate and frame of slot view.
//! @see RJSlotViewDelegate
- (id)initWithDelegate:(id<RJSlotViewDelegate>)aDelegate frame:(CGRect)aRect;

//! Delegate of slot view.
@property (nonatomic, unsafe_unretained) id<RJSlotViewDelegate> delegate;

//! Perform transition with specific animation to view.
- (void)transitionToView:(UIView *)aView animation:(NSString *)anAnimationType;

//! Removes ad view from superview.
- (void)removeAdView;

//! @see RJIntegrationType type for more info.
//! Default value: kRJIntegrationRevJetSDKDirect
@property (nonatomic, assign) RJIntegrationType integrationType;

//! Checks if slot view is currently inside the window.
@property (nonatomic, assign) BOOL isSlotViewVisible;

@end
