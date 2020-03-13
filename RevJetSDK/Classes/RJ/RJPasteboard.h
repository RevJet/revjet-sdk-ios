//
//  RJPasteboard.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIPasteboard.h>

@interface RJPasteboard : NSObject

+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;

@end
