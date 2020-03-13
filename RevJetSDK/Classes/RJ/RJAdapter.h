//
//  RJAdapter.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBaseAdapter.h"
#import "RJWebBrowserDelegate.h"

@interface RJAdapter : RJBaseAdapter <UIWebViewDelegate, RJWebBrowserDelegate>

@end
