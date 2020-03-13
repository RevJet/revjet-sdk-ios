//
//  RJVASTToolbarView.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTToolbarView.h"

#import "RJVASTToolbarViewCloseButton.h"
#import "RJVASTToolbarViewLearnMoreButton.h"
#import "RJVASTToolbarViewCountdownElement.h"

#import "RJUtilities.h"

static NSTimeInterval const kRJHideDurationTime = 0.2f;

@interface RJVASTToolbarView ()

@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) RJVASTToolbarViewCountdownElement *countdownElement;

@end

@implementation RJVASTToolbarView

- (void)initializeElements
{
	self.backgroundColor = [UIColor blackColor];
	self.alpha = 0.6f;
	
	self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 120.0f,
				self.frame.size.height)];
	self.durationLabel.textColor = [UIColor whiteColor];
	self.durationLabel.backgroundColor = [UIColor clearColor];
	self.durationLabel.font = [UIFont systemFontOfSize:12.0f];
	[self addSubview:self.durationLabel];
	
	self.closeButton = [[RJVASTToolbarViewCloseButton alloc] initWithFrame:CGRectMake(
				self.frame.size.width - 70.0f, 0.0f,
				70.0, self.frame.size.height)];
	self.closeButton.hidden = YES;
	[self addSubview:self.closeButton];
	
	self.countdownElement = [[RJVASTToolbarViewCountdownElement alloc] initWithFrame:CGRectMake(
				self.frame.size.width - 70.0f, 0.0f,
				70.0, self.frame.size.height)];
	self.countdownElement.hidden = YES;
	[self addSubview:self.countdownElement];
	
	self.learnMoreButton = [[RJVASTToolbarViewLearnMoreButton alloc] initWithFrame:CGRectMake(
				self.frame.size.width - self.closeButton.frame.size.width - 110.0f, 0.0f,
				100.0, self.frame.size.height)];
	self.learnMoreButton.hidden = YES;
	[self addSubview:self.learnMoreButton];
}

#pragma mark - Private

- (void)updateDuration:(NSTimeInterval)aDuration
{
	aDuration = ceilf(aDuration);
	if (aDuration > kRJHideDurationTime)
	{
		NSString *theDuration = [NSString stringWithFormat:@"%d", (int)aDuration];
		NSString *theSuffix = @"seconds";
		if ([theDuration isEqualToString:@"1"])
		{
			theSuffix = @"second";
		}
		self.durationLabel.text = [NSString stringWithFormat:@"Ends in %@ %@", theDuration, theSuffix];
	}
	else if (aDuration >= 0)
	{
		self.durationLabel.text = @"Thanks for watching";
	}
}

- (void)updateCountdownElement:(NSTimeInterval)aDuration
{
	if (aDuration > 0 && self.countdownElement.isHidden)
	{
		self.countdownElement.hidden = NO;
		self.closeButton.hidden = YES;
	}
	
	aDuration = ceil(aDuration);
	self.countdownElement.countdownLabel.text = [NSString stringWithFormat:@"%d", (int)aDuration];
}

- (void)makeInteractable
{
	self.countdownElement.hidden = YES;
	self.closeButton.hidden = NO;
	self.learnMoreButton.hidden = NO;
}

@end
