//
//  RJBaseAdapter.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RJAdapterDelegate;
@class RJPixelsTracker;

//! A key for accessing the additional data value from <code>params</code> dictionary.
//! If network data value is present in parameters (usually it needs for "Custom" network type) you can access
//! it in the following way:
//! <code>NSString *theDataValue = [aBaseAdapter.params objectForKey:kRJDataParameterKey];</code>
//! "theDataValue" can be <code>nil</code>
//! @see params property
extern NSString *const kRJDataParameterKey;

//! A base implementor fo adapter. If you want to implement your custom adapter it should be inherited from
//! this class.
@interface RJBaseAdapter : NSObject

//! A delegate object for adapter.
//! @see RJAdapterDelegate interface for more info.
@property (nonatomic, unsafe_unretained) id<RJAdapterDelegate> delegate;

@property (nonatomic, strong) RJPixelsTracker *pixelsTracker;

@property (nonatomic, copy) NSString *transitionAnimation;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, assign) BOOL showCloseButton;

//! Initializes <code>RJBaseAdapter</code> object with delegate.
//! @see RJAdapterDelegate interface for more info about which methods delegate must implement.
- (id)initWithDelegate:(id<RJAdapterDelegate>)aDelegate;
- (void)getAd;

//! Override this method if you want to add behavior for adapter when ad is shown.
- (void)didShowAd;

@end
