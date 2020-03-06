//
//  RJVASTMediaFileRepresentation.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTMediaFileRepresentation.h"

static NSString *const kRJMediaFileURL = @"MediaFileURL";

@implementation RJVASTMediaFileRepresentation

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	self = [super initWithDictionary:aDictionary];
	if (nil != self)
	{
		self.videoURL = [aDictionary objectForKey:kRJMediaFileURL];
	}
	
	return self;
}

@end
