//
//  RJVASTComponentRepresentation.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTComponentRepresentation.h"

static NSString *const kRJWidth = @"width";
static NSString *const kRJHeight = @"height";
static NSString *const kRJType = @"type";

@implementation RJVASTComponentRepresentation

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (nil == aDictionary)
	{
		return nil;
	}
	
	self = [super init];
	if (nil != self)
	{
		self.width = [[aDictionary objectForKey:kRJWidth] integerValue];
		self.height = [[aDictionary objectForKey:kRJHeight] integerValue];
		self.type = [aDictionary objectForKey:kRJType];
	}
	
	return self;
}

- (id)init
{
	return [self initWithDictionary:nil];
}

@end
