//
//  RJAppDelegate.m
//  RevJetSDK
//
//  Copyright (c) 2020 RevJet. All rights reserved.
//

#import "RJAppDelegate.h"
#import "RJViewController.h"

@interface RJAppDelegate ()

@property (nonatomic, strong) RJViewController *viewController;

@end

@implementation RJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.viewController = [[RJViewController alloc] initWithNibName:@"RJViewController" bundle:nil];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
