//
//  RJVASTToolbarView.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJVASTToolbarViewCloseButton, RJVASTToolbarViewLearnMoreButton;

@interface RJVASTToolbarView : UIView

@property (nonatomic, strong) RJVASTToolbarViewCloseButton *closeButton;
@property (nonatomic, strong) RJVASTToolbarViewLearnMoreButton *learnMoreButton;

- (void)initializeElements;
- (void)updateDuration:(NSTimeInterval)aDuration;
- (void)updateCountdownElement:(NSTimeInterval)aDuration;
- (void)makeInteractable;

@end
