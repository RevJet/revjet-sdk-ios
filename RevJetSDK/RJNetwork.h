//
//  RJNetwork.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kRJParamParameters;
extern NSString *kRJUserAgent;

@class RJSlot;

//! A class responsible for managing adapters and request/response from the server.
@interface RJNetwork : NSObject

- (id)initWithSlot:(RJSlot *)aSlot;

- (void)loadAd;
- (void)fetchAd;
- (void)showAd;

@property (nonatomic, unsafe_unretained) RJSlot *slot;

@property (nonatomic, assign) BOOL useRequestId;
@property (nonatomic, strong) NSString *requestId;

- (void)stopBeingDelegate;

@end
