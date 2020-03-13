//
//  RJBaseInterstitialController.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RJInterstitialControllerDelegate;

@interface RJBaseInterstitialController : UIViewController

@property (nonatomic, unsafe_unretained) id<RJInterstitialControllerDelegate> delegate;

@property (nonatomic, strong) NSString *HTML;
@property (nonatomic, assign) BOOL showCloseButton;
@property (nonatomic, assign) CGSize adSize;

- (id)initWithDelegate:(id<RJInterstitialControllerDelegate>)aDelegate html:(NSString *)aHTML
			showCloseButton:(BOOL)aFlag adSize:(CGSize)aSize;
- (void)loadAd;

- (CGRect)preferredwebViewFrame;

- (void)didPresentInterstitial;
- (void)didDismissInterstitial;

@end
