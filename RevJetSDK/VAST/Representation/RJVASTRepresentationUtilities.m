//
//  RJVASTRepresentationUtilities.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTRepresentationUtilities.h"

#import "RJVASTMediaFileRepresentation.h"
#import "RJVASTCompanionAdRepresentation.h"
#import "RJGlobal.h"

NSString *const kRJVASTVideoTypeMP4 = @"mp4";
NSString *const kRJVASTVideoType3GPP = @"3gpp";

NSString *const kRJVASTVersion = @"VAST 2.0 Wrapper";

@implementation RJVASTRepresentationUtilities

+ (RJVASTMediaFileRepresentation *)bestMediaFileRepresentation:(NSArray *)aRepresentations
{
	if ([aRepresentations count] == 0)
	{
		return nil;
	}
	
	static NSSet *sMediaFileTypes = nil;
	static dispatch_once_t sMediaFileTypesDispatch = 0;
	dispatch_once(&sMediaFileTypesDispatch, ^
	{
		sMediaFileTypes = [NSSet setWithArray:@[
					[NSString stringWithFormat:@"video/%@", kRJVASTVideoTypeMP4],
					[NSString stringWithFormat:@"video/%@", kRJVASTVideoType3GPP]
		]];
	});
	
	RJVASTMediaFileRepresentation *theBestMediaFileRepresentation = nil;
	float theBestFitness = MAXFLOAT;
	for (RJVASTMediaFileRepresentation *theRepresentation in aRepresentations)
	{
		if ([sMediaFileTypes containsObject:theRepresentation.type])
		{
			float theFitness = [RJVASTRepresentationUtilities calculateFitness:theRepresentation.width
																		height:theRepresentation.height];
			if (theFitness < theBestFitness)
			{
				theBestFitness = theFitness;
				theBestMediaFileRepresentation = theRepresentation;
			}
		}
	}
	
	return theBestMediaFileRepresentation;
}

+ (RJVASTCompanionAdRepresentation *)bestCompanionAdRepresentation:(NSArray *)aRepresentations
{
	if ([aRepresentations count] == 0)
	{
		return nil;
	}
	
	static NSSet *sCompanionAdTypes = nil;
	static dispatch_once_t sCompanionAdTypesDispatch = 0;
	dispatch_once(&sCompanionAdTypesDispatch, ^
	{
		sCompanionAdTypes = [NSSet setWithArray:@[ @"image/jpeg", @"image/png", @"image/bmp", @"image/gif" ]];
	});
	
	RJVASTCompanionAdRepresentation *theBestComanionAdRepresentation = nil;
	float theBestFitness = MAXFLOAT;
	for (RJVASTCompanionAdRepresentation *theRepresentation in aRepresentations)
	{
		if ([sCompanionAdTypes containsObject:theRepresentation.type])
		{
			float theFitness = [RJVASTRepresentationUtilities calculateFitness:theRepresentation.width
																		height:theRepresentation.height];
			if (theFitness < theBestFitness)
			{
				theBestFitness = theFitness;
				theBestComanionAdRepresentation = theRepresentation;
			}
		}
	}
	
	return theBestComanionAdRepresentation;
}

+ (NSString *)supportedVideoTypesSeparatedByComma
{
	NSArray *theTypes = @[ kRJVASTVideoTypeMP4, kRJVASTVideoType3GPP ];
	return [theTypes componentsJoinedByString:@","];
}

#pragma mark - Private

+ (float)calculateFitness:(float)width height:(float)height
{
	CGSize theScreenSize = [RJGlobal screenSizeFixedToPortraitOrientation];
	float theScreenWidth = MAX(theScreenSize.width, theScreenSize.height);
	float theScreenHeight = MAX(theScreenSize.width, theScreenSize.height);
	
	float theScreenAspectRatio = theScreenWidth / theScreenHeight;
	float theScreenArea = theScreenWidth * theScreenHeight;
	
	float theMediaAspectRatio = width / height;
	float theMediaArea = width * height;
	
	float theAspectRatio = theMediaAspectRatio / theScreenAspectRatio;
	float theArea = theMediaArea / theScreenArea;
	return 40.0f * fabs(logf(theAspectRatio)) + 60.0f * fabs(logf(theArea));
}

@end
