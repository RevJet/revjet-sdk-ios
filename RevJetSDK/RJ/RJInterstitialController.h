//
//  RJInterstitialController.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJBaseInterstitialController.h"

@protocol RJInterstitialControllerDelegate;

@interface RJInterstitialController : RJBaseInterstitialController<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end
