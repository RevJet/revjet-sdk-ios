//
//  RJVASTXMLParserAggregator.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJVASTXMLParserAggregator : NSObject

- (void)parseVASTXML:(NSString *)aXMLString
			withHandler:(void (^) (NSDictionary *aParameters))aHandler;

@end
