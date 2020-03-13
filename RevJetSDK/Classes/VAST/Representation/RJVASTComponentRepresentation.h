//
//  RJVASTComponentRepresentation.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJVASTComponentRepresentation : NSObject

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSString *type;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

@end
