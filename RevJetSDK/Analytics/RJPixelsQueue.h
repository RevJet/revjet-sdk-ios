//
//  RJPixelsQueue.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJPixelsQueue : NSObject

+ (RJPixelsQueue *)defaultQueue;

- (void)addPixelToQueue:(NSURL *)aPixelURL;
- (void)addStringPixelToQueue:(NSString *)aPixelString;
- (void)addStringPixelsToQueue:(NSArray *)aStringPixels;

@end
