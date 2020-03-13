//
//  RJStoreProductViewController.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@class RJBaseAdapter;

@interface RJStoreProductViewController : SKStoreProductViewController

@property (nonatomic, strong) RJBaseAdapter *adapter;

@end
