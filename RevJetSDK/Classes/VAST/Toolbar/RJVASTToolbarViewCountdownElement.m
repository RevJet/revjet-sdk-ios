//
//  RJVASTToolbarViewCountdownElement.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTToolbarViewCountdownElement.h"

@implementation RJVASTToolbarViewCountdownElement

- (void)drawRect:(CGRect)aRect
{
	aRect = CGRectMake(40.0f, 2.0f, aRect.size.height - 15.0f, aRect.size.height);
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	CGContextAddEllipseInRect(theContext, CGRectMake(
				42.0f, 10.0f, aRect.size.width - 4.0f, aRect.size.width - 4.0f));
	
	CGContextSetStrokeColorWithColor(theContext, [UIColor whiteColor].CGColor);
	CGContextStrokePath(theContext);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (nil == self.countdownLabel)
	{
		self.countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(
					50.0f, 2.0f, self.frame.size.height - 4.0f, self.frame.size.height - 4.0f)];
		self.countdownLabel.textColor = [UIColor whiteColor];
		self.countdownLabel.backgroundColor = [UIColor clearColor];
		self.countdownLabel.font = [UIFont systemFontOfSize:10.0f];
		[self addSubview:self.countdownLabel];
	}
}

@end
