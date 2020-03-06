//
//  DemoViewController.h
//  RevJetSimpleDemoApp
//
//  Copyright © 2020 RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RevJetSDK/RevJetSDK.h>

@interface DemoViewController : UIViewController<RJSlotDelegate>

@property (nonatomic, strong) RJSlot *slot;

@end
