//
//  RJCustomEventAdapter.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJGlobal.h"
#import "RJCustomEventAdapter.h"
#import "RJAdapterDelegate.h"

@interface RJCustomEventAdapter()
- (void)reportError:(NSString *)msg;
@end

@implementation RJCustomEventAdapter

- (void)dealloc {
  RJLog(@"dealloc");

  NSString *function = self.params[@"FUNCTION"];
  if (function != nil && [function length] > 0) {
    [self.delegate runDeallocCustomFunction:function withObject:self];
  }

}

- (void)getAd {
  [super getAd];
  RJLog(@"getAd");

  NSString *function = self.params[@"FUNCTION"];
  if (!function || [function length] <= 0) {
    [self reportError:@"Custom function isn't defined"];
    return;
  }

  if (![self.delegate runCustomFunction:function withObject:self]) {
    [self reportError:@"Slot delegate doesn't implement custom function"];
  }
}

- (void)reportError:(NSString *)msg {
  NSDictionary *dict = @{NSLocalizedDescriptionKey: NSLocalizedString(msg, @"")};
  NSError *error = [NSError errorWithDomain:kRJErrorDomain code:502 userInfo:dict];
  [self.delegate adapter:self didFailToReceiveAd:nil error:error];
}

@end
