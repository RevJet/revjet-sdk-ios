//
//  RJSlotViewDelegate.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJSlotView;

@protocol RJSlotViewDelegate <NSObject>

- (void)slotView:(RJSlotView *)aSlotView didShowAd:(UIView *)aView;

@end
