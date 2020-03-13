//
//  RJViewController.h
//  RevJetSDK
//
//  Copyright (c) 2020 RevJet. All rights reserved.
//

@import UIKit;
#import <RevJetSDK/RevJetSDK.h>

@interface RJViewController : UIViewController<RJSlotDelegate>

@property (nonatomic, strong) RJSlot *slot;

@end
