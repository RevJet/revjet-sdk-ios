//
//  RJPasteboard.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJPasteboard.h"

static NSString * const kRJPasteboard = @"com.revjet.pasteboard";

@interface RJPasteboard()
+ (void)setDict:(id)dict forKey:(NSString *) key;
+ (NSDictionary *)getDictForKey:(NSString *) key;
+ (UIPasteboard *)pasteboardForKey:(NSString *)key create:(BOOL)create;
+ (NSString *)pasteboardIdForKey:(NSString *)key; 
@end

@implementation RJPasteboard

#pragma mark public

+ (void)setObject:(id)object forKey:(NSString *)key {
  NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow: 3600*24*14];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        object, @"value", deadline, @"deadline", nil];
  [self setDict:dict forKey:key];
}

+ (id)objectForKey:(NSString *)key {
  NSDictionary *dict = [self getDictForKey:key];
  if (!dict) {
    return nil;
  }

  NSDate *deadline = [dict objectForKey:@"deadline"];
  if (NSOrderedAscending == [deadline compare:[NSDate date]]) { // deadline passed
    [self removeObjectForKey:key]; //remove expired pasteboard too
    return nil;
  }

  return [dict objectForKey:@"value"];
}

+ (void)removeObjectForKey:(NSString *)key {
  if ([self pasteboardForKey:key create:NO]) { // remove only existing pasteboa
    [UIPasteboard removePasteboardWithName:[self pasteboardIdForKey:key]];
  }
}

#pragma mark private

+ (NSString *)pasteboardIdForKey:(NSString *)key {
  return [NSString stringWithFormat:@"%@.%@", kRJPasteboard, key];
}

+ (UIPasteboard *)pasteboardForKey:(NSString *)key create:(BOOL)create {
  UIPasteboard *pboard = [UIPasteboard pasteboardWithName:
                          [self pasteboardIdForKey:key] create:create];
//  if (create && !pboard.persistent) {
//    pboard.persistent = YES;
//  }

  return pboard;
}

+ (void)setDict:(id)dict forKey:(NSString *)key {
  UIPasteboard *pboard = [self pasteboardForKey:key create:YES];
  [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict]
forPasteboardType:[self pasteboardIdForKey:key]];
}

+ (NSDictionary *)getDictForKey:(NSString *)key {
  UIPasteboard *pboard = [self pasteboardForKey:key create:NO];
  id item = nil;
  if (pboard) {
    item = [pboard dataForPasteboardType:[self pasteboardIdForKey:key]];
    if (item) {
      item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
    }
  }

  if (item != nil && [item isKindOfClass:[NSDictionary class]]
      && [item count] > 1) {
    return [NSDictionary dictionaryWithDictionary:item];
  }

  return nil;
}

@end
