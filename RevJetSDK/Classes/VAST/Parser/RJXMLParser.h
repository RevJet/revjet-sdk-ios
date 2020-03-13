//
//  RJXMLParser.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJVASTAdRepresentation;

@interface RJXMLParser : NSObject

- (id)initWithXMLString:(NSString *)aXMLString;
- (void)parseWithHandler:(void (^) (RJVASTAdRepresentation *anAdRepresentation))aHandler;

@end
