//
//  AppDelegate.m
//  RevJetSimpleDemoApp
//
//  Copyright © 2020 RevJet. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) DemoViewController *viewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.viewController = [[DemoViewController alloc] initWithNibName:@"DemoViewController" bundle:nil];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}


@end
