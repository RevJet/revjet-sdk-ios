//
//  RJMRAIDView.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger kRJExpandedWebViewTag = 0xBABE;

typedef enum {
  kRJMRAIDPlacementTypeInline,
  kRJMRAIDPlacementTypeInterstitial
} kRJMRAIDPlacementType;

@class RJMRAID;
@protocol RJMRAIDViewDelegate;

@interface RJMRAIDView : UIView

@property(nonatomic, unsafe_unretained) id<RJMRAIDViewDelegate> delegate;
@property(nonatomic, assign) kRJMRAIDPlacementType placementType;
@property(nonatomic, readonly) UIWebView * webView;
@property(nonatomic, readonly) UIWebView * expandedWebView;
@property(nonatomic, readonly) RJMRAID * mraid;

- (id)initWithFrame:(CGRect)aFrame delegate:(id<RJMRAIDViewDelegate>)aDelegate;
- (void)loadHTML:(NSString *)aHTML;

- (BOOL)isExpandedWebView;
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)aScript;
- (void)expandToSize:(CGSize)aSize withContent:(NSString *)aContent;
- (void)closeExpandedView;

- (void)hiddenState;
- (void)showCloseButton;
- (void)hideCloseButton;

- (void)lockOrientation:(BOOL)lockOrientation force:(NSNumber *)aForceOrientationMask;

@end
