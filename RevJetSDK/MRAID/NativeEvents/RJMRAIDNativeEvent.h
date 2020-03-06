//
//  RJMRAIDNativeEvent.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RJMRAIDNativeEventDelegate;
@class RJMRAIDView;

@interface RJMRAIDNativeEvent : NSObject

@property (nonatomic, unsafe_unretained) id<RJMRAIDNativeEventDelegate> delegate;
@property (nonatomic, strong) NSString *eventName;

- (id)initWithDelegate:(id<RJMRAIDNativeEventDelegate>)aDelegate;
- (void)executeEventWithParameters:(NSDictionary *)aParameters;

- (void)reportErrorWithMessage:(NSString *)aMessage;

@end

@protocol RJMRAIDNativeEventDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;
- (RJMRAIDView *)MRAIDView;

- (void)nativeEventWillPresentModalView:(RJMRAIDNativeEvent *)anEvent;
- (void)nativeEventDidDismissModalView:(RJMRAIDNativeEvent *)anEvent;
- (void)nativeEvent:(RJMRAIDNativeEvent *)anEvent didFailExecute:(NSError *)anError;

- (BOOL)useCustomCloseButton;
- (void)nativeEvent:(RJMRAIDNativeEvent *)anEvent willUseCutomCloseButton:(BOOL)aFlag;

- (void)nativeEventWillRequestAccess:(RJMRAIDNativeEvent *)anEvent;
- (void)nativeEventDidRequestAccess:(RJMRAIDNativeEvent *)anEvent;

@end
