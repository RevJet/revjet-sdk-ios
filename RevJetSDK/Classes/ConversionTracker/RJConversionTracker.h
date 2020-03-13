//  RJConversionTracker.h
//  RevJetSDK

//  Copyright (c) RevJet. All rights reserved.


#import <Foundation/Foundation.h>

//! A sigleton class for conversion. You should use this class for enable conversion tracking.
@interface RJConversionTracker : NSObject

//! Returns a shared instance of <code>sharedConversionTracker</code> object.
+ (RJConversionTracker *)sharedConversionTracker;

//! Enable tracking of conversion.
- (void)reportApplicationDidFinishLaunching;

@end