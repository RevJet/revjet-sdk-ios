//
//  RJVASTInterstitialController.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJBaseInterstitialController.h"

@class RJVASTAdRepresentation;

@interface RJVASTInterstitialController : RJBaseInterstitialController

- (id)initWithDelegate:(id<RJInterstitialControllerDelegate>)aDelegate
			adRepresentation:(RJVASTAdRepresentation *)aRepresentation;

@end
