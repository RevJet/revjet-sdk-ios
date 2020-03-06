//
//  RJSlotURL.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJSlot;

@interface RJURL : NSObject

+ (NSString *)urlForSlot:(RJSlot *)aSlot;
+ (NSString *)stringURLForSlotTag:(NSString *)aSlotTag;

+ (NSMutableDictionary *)parametersForSlot:(NSString *)aSlotTag;
+ (NSString *)stringURLWithTargetingForSlotTag:(NSString *)aSlotTag slot:(RJSlot *)aSlot;
+ (NSDictionary *)targetingParametersForSlot:(RJSlot *)aSlot;

//! Returns slot tag from the tag ULR (e.g. slot49814)
+ (NSString *)slotTagFromSlotURL:(NSString *)aSlotURL;

@end
