//
//  RJMRAIDNativeEventFactory.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJMRAIDNativeEvent;
@protocol RJMRAIDNativeEventDelegate;

@interface RJMRAIDNativeEventFactory : NSObject

+ (RJMRAIDNativeEvent *)eventWithName:(NSString *)anEventName
							 delegate:(id<RJMRAIDNativeEventDelegate>)aDelegate;

@end
