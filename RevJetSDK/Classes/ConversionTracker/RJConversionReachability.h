//  RJConversionReachability.h
//  RevJetSDK

//  Copyright (c) RevJet. All rights reserved.

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <netinet/in.h>

//! Posts this notification when reachability status is changed.
//! @see RJConversionReachabilityStatusType for more info about possible states.
extern NSString *const kRJReachabilityStatusChanged;

//! An anumeration of possible status of reachability.
typedef enum
{
	kRJConversionReachabilityStatusNotReachable = 0,
	kRJConversionReachabilityStatusWiFi,
	kRJConversionReachabilityStatusWWAN
} RJConversionReachabilityStatusType;

//! A class which provides abstraction of reachability checker. Use <code>reachabilityWithHostName:</code>,
//! <code>reachabilityWithAddress:</code>, <code>reachabilityForInternetConnection</code> and
//! <code>reachabilityForLocalWiFi</code> methods for get instance of this class.
@interface RJConversionReachability: NSObject

//! Use to check the reachability of a particular host name.
+ (RJConversionReachability *)reachabilityWithHostName:(NSString*)aHostName;

//! Use to check the reachability of a particular IP address.
+ (RJConversionReachability *)reachabilityWithAddress:(const struct sockaddr_in *)aHostAddress;

//! Checks whether the default route is available.
//! Should be used by applications that do not connect to a particular host
+ (RJConversionReachability *)reachabilityForInternetConnection;

//! Checks whether a local wifi connection is available.
+ (RJConversionReachability *)reachabilityForLocalWiFi;

//! Start listening for reachability notifications on the current run loop.
- (BOOL)startNotifier;

//! Stop listening for reachability notifications on the current run loop.
- (void)stopNotifier;

- (RJConversionReachabilityStatusType)currentReachabilityStatus;

//! WWAN may be available, but not active until a connection has been established.
//! WiFi may require a connection for VPN on Demand.
- (BOOL)connectionRequired;

@end
