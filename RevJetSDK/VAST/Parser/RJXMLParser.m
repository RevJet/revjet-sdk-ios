//
//  RJXMLParser.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJXMLParser.h"

#import "RJGlobal.h"
#import "RJVASTAdRepresentation.h"

static NSString *const kRJImpression = @"Impression";
static NSString *const kRJClickThrough = @"ClickThrough";

static NSString *const kRJMediaFile = @"MediaFile";
static NSString *const kRJMediaFiles = @"MediaFiles";

static NSString *const kRJStaticResource = @"StaticResource";
static NSString *const kRJCompanion = @"Companion";
static NSString *const kRJCompanionAds = @"CompanionAds";
static NSString *const kRJCompanionClickThrough = @"CompanionClickThrough";

static NSString *const kRJTrackingEvents = @"TrackingEvents";
static NSString *const kRJTracking = @"Tracking";
static NSString *const kRJClickTracking = @"ClickTracking";

static NSString *const kRJVASTAdTagURI = @"VASTAdTagURI";

@interface RJXMLParser () <NSXMLParserDelegate>

@property (nonatomic, strong) NSString *XMLString;
@property (copy)void (^handler)(RJVASTAdRepresentation *);

@property (nonatomic, strong) NSMutableDictionary *parsingResult;

@property (nonatomic, strong) NSString *currentString;
@property (nonatomic, strong) NSMutableDictionary *currentComponent;
@property (nonatomic, strong) NSMutableArray *currentComponents;

@property (nonatomic, strong) NSMutableArray *currentTrackingEvents;
@property (nonatomic, strong) NSMutableDictionary *currentTrackingEvent;

@property (nonatomic, strong) NSMutableArray *clickTrackingURLs;
@property (nonatomic, strong) NSMutableArray *clickThroughURLs;
@property (nonatomic, strong) NSMutableArray *impressionsURLs;

@property (nonatomic, assign) BOOL isParsingCompanionAd;

@end

@implementation RJXMLParser

- (id)initWithXMLString:(NSString *)aXMLString
{
	if (nil == aXMLString)
	{
		return nil;
	}
	
	self = [super init];
	if (nil != self)
	{
		self.XMLString = aXMLString;
	}
	
	return self;
}

- (id)init
{
	return [self initWithXMLString:nil];
}

#pragma mark -

- (void)parseWithHandler:(void (^) (RJVASTAdRepresentation *anAdRepresentation))aHandler;
{
	self.parsingResult = [[NSMutableDictionary alloc] init];
	self.handler = aHandler;
	
	NSData *theXMLData = [self.XMLString dataUsingEncoding:NSUTF8StringEncoding];
	NSXMLParser *theParser = [[NSXMLParser alloc] initWithData:theXMLData];
	theParser.delegate = self;
	if (![theParser parse])
	{
		NSError *theError = [theParser parserError];
		if (nil != theError)
		{
			RJLog(@"Error occured during parsing: %@", theError);
		}
		self.handler(nil);
	}
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)aParser
{
}

- (void)parser:(NSXMLParser *)aParser didStartElement:(NSString *)anElementName
			namespaceURI:(NSString *)aNamespaceURI qualifiedName:(NSString *)aQName
			attributes:(NSDictionary *)anAttributeDict
{
	if ([anElementName isEqualToString:kRJMediaFiles] ||
				[anElementName isEqualToString:kRJCompanionAds])
	{
		self.currentComponents = [NSMutableArray array];
	}
	else if ([anElementName isEqualToString:kRJMediaFile] ||
				[anElementName isEqualToString:kRJCompanion])
	{
		self.currentComponent = [NSMutableDictionary dictionary];
		if (nil != anAttributeDict)
		{
			[self.currentComponent addEntriesFromDictionary:anAttributeDict];
		}
		
		if ([anElementName isEqualToString:kRJCompanion])
		{
			self.isParsingCompanionAd = YES;
		}
	}
	else if ([anElementName isEqualToString:kRJTrackingEvents])
	{
		self.currentTrackingEvents = [NSMutableArray array];
	}
	else if ([anElementName isEqualToString:kRJTracking])
	{
		self.currentTrackingEvent = [NSMutableDictionary dictionary];
		if (nil != anAttributeDict)
		{
			[self.currentTrackingEvent addEntriesFromDictionary:anAttributeDict];
		}
	}
	else if ([anElementName isEqualToString:kRJStaticResource])
	{
		if (nil != anAttributeDict)
		{
			[self.currentComponent addEntriesFromDictionary:anAttributeDict];
		}
	}
	else if ([anElementName isEqualToString:kRJClickTracking])
	{
		if (nil == self.clickTrackingURLs)
		{
			self.clickTrackingURLs = [NSMutableArray array];
		}
	}
	else if ([anElementName isEqualToString:kRJClickThrough])
	{
		if (nil == self.clickThroughURLs)
		{
			self.clickThroughURLs = [NSMutableArray array];
		}
	}
}

- (void)parser:(NSXMLParser *)aParser foundCharacters:(NSString *)aString
{
	NSString *theFixedString = [aString stringByReplacingOccurrencesOfString:@"\\s"
				withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [aString length])];
	if (![theFixedString isEqualToString:[NSString string]])
	{
		self.currentString = theFixedString;
	}
}

- (void)parser:(NSXMLParser *)aParser didEndElement:(NSString *)anElementName
			namespaceURI:(NSString *)aNamespaceURI qualifiedName:(NSString *)aQName
{
	if ([anElementName isEqualToString:kRJImpression])
	{
		if (nil == self.impressionsURLs)
		{
			self.impressionsURLs = [NSMutableArray array];
			if (nil != self.currentString)
			{
				[self.impressionsURLs addObject:self.currentString];
			}
		}
	}
	else if ([anElementName isEqualToString:kRJMediaFile])
	{
		if (nil != self.currentString)
		{
			[self.currentComponent setObject:self.currentString forKey:@"MediaFileURL"];
		}
		[self.currentComponents addObject:self.currentComponent];
	}
	else if ([anElementName isEqualToString:kRJMediaFiles])
	{
		[self.parsingResult setObject:self.currentComponents forKey:kRJMediaFiles];
	}
	else if ([anElementName isEqualToString:kRJTracking])
	{
		if (nil != self.currentString)
		{
			[self.currentTrackingEvent setObject:self.currentString forKey:@"URL"];
		}
		[self.currentTrackingEvents addObject:self.currentTrackingEvent];
	}
	else if ([anElementName isEqualToString:kRJTrackingEvents])
	{
		if (!self.isParsingCompanionAd)
		{
			NSMutableArray *theTrackingEvents = [NSMutableArray arrayWithArray:
						[self.parsingResult objectForKey:kRJTrackingEvents]];
			if (nil == theTrackingEvents)
			{
				theTrackingEvents = self.currentTrackingEvents;
			}
			else
			{
				[theTrackingEvents addObjectsFromArray:self.currentTrackingEvents];
			}
			[self.parsingResult setObject:theTrackingEvents forKey:kRJTrackingEvents];
		}
		else
		{
			[self.currentComponent setObject:self.currentTrackingEvents forKey:kRJTrackingEvents];
		}
	}
	else if ([anElementName isEqualToString:kRJCompanion])
	{
		[self.currentComponents addObject:self.currentComponent];
		self.isParsingCompanionAd = NO;
	}
	else if ([anElementName isEqualToString:kRJCompanionAds])
	{
		[self.parsingResult setObject:self.currentComponents forKey:kRJCompanionAds];
	}
	else if ([anElementName isEqualToString:kRJStaticResource])
	{
		[self.currentComponent setObject:self.currentString forKey:@"CompanionAdURL"];
	}
	else if ([anElementName isEqualToString:kRJCompanionClickThrough])
	{
		if (nil != self.currentString)
		{
			[self.currentComponent setObject:self.currentString forKey:kRJCompanionClickThrough];
		}
	}
	else if ([anElementName isEqualToString:kRJClickTracking])
	{
		if (nil != self.currentString)
		{
			[self.clickTrackingURLs addObject:self.currentString];
		}
	}
	else if ([anElementName isEqualToString:kRJClickThrough])
	{
		if (nil != self.currentString)
		{
			[self.clickThroughURLs addObject:self.currentString];
		}
	}
	else if ([anElementName isEqualToString:kRJVASTAdTagURI] &&
				(nil == [self.parsingResult objectForKey:kRJVASTAdTagURI]))
	{
		if (nil != self.currentString)
		{
			[self.parsingResult setObject:self.currentString forKey:kRJVASTAdTagURI];
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)aParser
{
	if (nil != self.clickTrackingURLs)
	{
		[self.parsingResult setObject:self.clickTrackingURLs forKey:kRJClickTracking];
	}
	if (nil != self.impressionsURLs)
	{
		[self.parsingResult setObject:self.impressionsURLs forKey:kRJImpression];
	}
	if (nil != self.clickThroughURLs)
	{
		[self.parsingResult setObject:self.clickThroughURLs forKey:kRJClickThrough];
	}
	RJVASTAdRepresentation *theAdRepresentation = [[RJVASTAdRepresentation alloc]
				initWithDictionary:self.parsingResult];
	self.handler(theAdRepresentation);
}

@end
