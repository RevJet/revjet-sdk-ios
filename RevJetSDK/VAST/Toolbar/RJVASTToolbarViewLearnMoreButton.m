//
//  RJVASTToolbarViewLearnMoreButton.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTToolbarViewLearnMoreButton.h"

@interface RJVASTToolbarViewLearnMoreButton ()

@property (nonatomic, strong) UILabel *learnMoreLabel;

@end

@implementation RJVASTToolbarViewLearnMoreButton

- (void)drawRect:(CGRect)aRect
{
	aRect = CGRectMake(70.0f, 2.0f, aRect.size.height - 15.0f, aRect.size.height);
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	CGContextAddEllipseInRect(theContext, CGRectMake(
				72.0f, 10.0f, aRect.size.width - 4.0f, aRect.size.width - 4.0f));
	
	CGContextMoveToPoint(theContext, aRect.size.width / 2.0f - 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f + 5.0f);
	CGContextAddLineToPoint(theContext, aRect.size.width / 2.0f + 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f - 5.0f);
	
	CGContextMoveToPoint(theContext, aRect.size.width / 2.0f + 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f - 5.0f);
	CGContextAddLineToPoint(theContext, aRect.size.width / 2.0f + 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f);
	
	CGContextMoveToPoint(theContext, aRect.size.width / 2.0f + 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f - 5.0f);
	CGContextAddLineToPoint(theContext, aRect.size.width / 2.0f + aRect.origin.x,
				aRect.size.height / 2.0f - 5.0f);
	
	CGContextSetStrokeColorWithColor(theContext, (
				self.isHighlighted ? [UIColor darkGrayColor].CGColor : [UIColor whiteColor].CGColor));
	CGContextStrokePath(theContext);
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
	self.learnMoreLabel.textColor = highlighted ? [UIColor darkGrayColor] : [UIColor whiteColor];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (nil == self.learnMoreLabel)
	{
		self.learnMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(
					0.0f, 0.0f, 70.0f, self.frame.size.height)];
		self.learnMoreLabel.textColor = [UIColor whiteColor];
		self.learnMoreLabel.backgroundColor = [UIColor clearColor];
		self.learnMoreLabel.font = [UIFont systemFontOfSize:12.0f];
		self.learnMoreLabel.text = @"Learn More";
		[self addSubview:self.learnMoreLabel];
	}
}

@end
