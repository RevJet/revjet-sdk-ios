//
//  RJVASTAdRepresentation.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJVASTMediaFileRepresentation, RJVASTCompanionAdRepresentation;

extern NSString *const kRJVASTAdRepresentationKey;

@interface RJVASTAdRepresentation : NSObject

@property (nonatomic, strong) NSMutableArray *impressions;
@property (nonatomic, strong) NSString *clickThrough;
@property (nonatomic, strong) NSMutableArray *clickTrackingEvents;

@property (nonatomic, strong) NSMutableArray *startTrackingEvents;
@property (nonatomic, strong) NSMutableArray *firstQuartileTrackingEvents;
@property (nonatomic, strong) NSMutableArray *midpointTrackingEvents;
@property (nonatomic, strong) NSMutableArray *thirdQuartileTrackingEvents;
@property (nonatomic, strong) NSMutableArray *completeTrackingEvents;

@property (nonatomic, strong) NSMutableArray *mediaFiles;
@property (nonatomic, strong) NSMutableArray *companionAds;

@property (nonatomic, strong) RJVASTMediaFileRepresentation *bestMediaFile;
@property (nonatomic, strong) RJVASTCompanionAdRepresentation *bestCompanionAd;

@property (nonatomic, strong) NSString *mediaFilePath;
@property (nonatomic, strong) NSString *companionAdPath;

@property (nonatomic, strong) NSString *adTagUri;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

- (void)addImpressions:(NSArray *)anImpressions;
- (void)addClickTrackingEvents:(NSArray *)anEvents;

- (void)addStartTrackingEvents:(NSArray *)anEvents;
- (void)addFirstQuartileTrackingEvents:(NSArray *)anEvents;
- (void)addMidpointTrackingEvents:(NSArray *)anEvents;
- (void)addThirdQuartileTrackingEvents:(NSArray *)anEvents;
- (void)addCompleteTrackingEvents:(NSArray *)anEvents;

- (void)addMediaFiles:(NSArray *)anEvents;
- (void)addCompanionAds:(NSArray *)anEvents;

@end
