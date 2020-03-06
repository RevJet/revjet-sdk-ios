//
//  RJVASTRepresentationUtilities.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJVASTMediaFileRepresentation, RJVASTCompanionAdRepresentation;

extern NSString *const kRJVASTVideoTypeMP4;
extern NSString *const kRJVASTVideoType3GPP;

extern NSString *const kRJVASTVersion;

@interface RJVASTRepresentationUtilities : NSObject

+ (RJVASTMediaFileRepresentation *)bestMediaFileRepresentation:(NSArray *)aRepresentations;
+ (RJVASTCompanionAdRepresentation *)bestCompanionAdRepresentation:(NSArray *)aRepresentations;

+ (NSString *)supportedVideoTypesSeparatedByComma;

@end
