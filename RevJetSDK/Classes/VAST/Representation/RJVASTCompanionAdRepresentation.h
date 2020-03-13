//
//  RJVASTCompanionAdRepresentation.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTComponentRepresentation.h"

@interface RJVASTCompanionAdRepresentation : RJVASTComponentRepresentation

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *clickThroughURL;
@property (nonatomic, strong) NSMutableArray *clickTrackers;

@end
