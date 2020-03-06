//
//  RJHTMLScanner.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJHTMLScanner.h"
#import "RJNetwork.h"

static NSInteger const kRJDefaultCapacity = 4;

static NSString *const kRJCSSContainer = @"#container";
static NSString *const kRJCSSContainerPrefix = @"{";
static NSString *const kRJCSSContainerSuffix = @"}";
static NSString *const kRJCSSContainerElementsSeparator = @";";
static NSString *const kRJCSSContainerSubElementsSeparator = @":";


@interface RJHTMLScanner ()

+ (NSDictionary *)getMetaParametersFromHTML:(NSString *)aBody;

@end

@implementation RJHTMLScanner

+ (NSDictionary *)getParametersFromHTML:(NSString *)aBody
{
	NSMutableDictionary *theParameters = [NSMutableDictionary dictionaryWithCapacity:kRJDefaultCapacity * 2];
	NSDictionary *theMetaParameters = [RJHTMLScanner getMetaParametersFromHTML:aBody];
	if (0 != [theMetaParameters count])
	{
		[theParameters addEntriesFromDictionary:theMetaParameters];
	}

	return @{kRJParamParameters: theParameters};
}

#pragma mark - Private

+ (NSDictionary *)getMetaParametersFromHTML:(NSString *)aBody
{
	NSMutableDictionary *theResultParameters = [NSMutableDictionary dictionaryWithCapacity:kRJDefaultCapacity];

	NSScanner *theScanner = [[NSScanner alloc] initWithString:aBody];
	[theScanner setCaseSensitive:NO];

	NSMutableArray *theMetaTags = [NSMutableArray arrayWithCapacity:kRJDefaultCapacity];

	// Extract meta tags
	while (![theScanner isAtEnd])
	{
		if ([theScanner scanUpToString:@"<meta" intoString:NULL])
		{
			NSString *theMetaTag = nil;
			if ([theScanner scanUpToString:@">" intoString:&theMetaTag])
			{
				[theMetaTags addObject:theMetaTag];
			}
		}
	}


	// Parse meta tags
	for (NSString *theMetaTag in theMetaTags)
	{
		// Scan for name
		theScanner = [[NSScanner alloc] initWithString:theMetaTag];
		[theScanner setCaseSensitive:NO];

		NSString *theNameValue = nil;
		if ([theScanner scanUpToString:@"name" intoString:NULL] && [theScanner scanUpToString:@"\"" intoString:NULL])
		{
			[theScanner setScanLocation:[theScanner scanLocation] + 1];
			[theScanner scanUpToString:@"\"" intoString:&theNameValue];
		}


		// Scan for content
		theScanner = [[NSScanner alloc] initWithString:theMetaTag];
		[theScanner setCaseSensitive:NO];

		NSString *theContentValue = nil;
		if ([theScanner scanUpToString:@"content" intoString:NULL] && [theScanner scanUpToString:@"\"" intoString:NULL])
		{
			[theScanner setScanLocation:[theScanner scanLocation] + 1];
			[theScanner scanUpToString:@"\"" intoString:&theContentValue];
		}


		if ((nil == theNameValue) || (nil == theContentValue))
		{
			continue;
		}
		
		NSCharacterSet *theWhitespaceAndNewLineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		theNameValue = [theNameValue stringByTrimmingCharactersInSet:theWhitespaceAndNewLineCharacterSet];
		theContentValue = [theContentValue stringByTrimmingCharactersInSet:theWhitespaceAndNewLineCharacterSet];
		
		NSRange paramRange = [theNameValue rangeOfString:@"Parameter-"];
		if ( paramRange.location != NSNotFound)
		{
			[theResultParameters setValue:theContentValue forKey:[theNameValue substringFromIndex:paramRange.length]];
		}
		else
		{
			[theResultParameters setValue:theContentValue forKey:theNameValue];
		}
	}
	
	return theResultParameters;
}

+ (NSDictionary *)getCSSParametersFromHTML:(NSString *)aBody
{
	NSMutableDictionary *theResult = [NSMutableDictionary dictionaryWithCapacity:kRJDefaultCapacity];
	NSScanner *theScanner = [[NSScanner alloc] initWithString:aBody];
	[theScanner setCaseSensitive:NO];

	// Extract meta tags
	while (![theScanner isAtEnd])
	{
		if ([theScanner scanUpToString:kRJCSSContainer intoString:NULL])
		{
			if ([theScanner scanUpToString:kRJCSSContainerPrefix intoString:NULL])
			{
				NSString *theContainerSection = nil;
				if ([theScanner scanUpToString:kRJCSSContainerSuffix intoString:&theContainerSection])
				{
					theContainerSection = [theContainerSection stringByReplacingOccurrencesOfString:kRJCSSContainerPrefix
								withString:[NSString string]];
					theContainerSection = [theContainerSection stringByReplacingOccurrencesOfString:@" "
								withString:[NSString string]];
					NSArray *theComponents = [theContainerSection componentsSeparatedByString:
								kRJCSSContainerElementsSeparator];
					for (NSString *theComponent in theComponents)
					{
						NSArray *theSubComponents = [theComponent componentsSeparatedByString:
									kRJCSSContainerSubElementsSeparator];
						if (2 == [theSubComponents count])
						{
							NSString *theKey = [theSubComponents objectAtIndex:0];
							if ((NSOrderedSame == [theKey caseInsensitiveCompare:@"width"]) ||
										(NSOrderedSame == [theKey caseInsensitiveCompare:@"height"]))
							{
								NSString *theValue = [theSubComponents objectAtIndex:1];
								NSInteger theIntegerValue = [theValue integerValue];
								if (0 != theIntegerValue)
								{
									NSNumber *theValueNumber = [NSNumber numberWithInteger:theIntegerValue];
									[theResult setValue:theValueNumber forKey:[theKey uppercaseString]];
								}
							}
						}
					}
				}
			}
		}
	}

	return theResult;
}

@end
