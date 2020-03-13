//
//  RJVASTToolbarViewCloseButton.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTToolbarViewCloseButton.h"

@interface RJVASTToolbarViewCloseButton ()

@property (nonatomic, strong) UILabel *closeLabel;

@end

@implementation RJVASTToolbarViewCloseButton

- (void)drawRect:(CGRect)aRect
{
	aRect = CGRectMake(40.0f, 2.0f, aRect.size.height - 15.0f, aRect.size.height);
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	CGContextAddEllipseInRect(theContext, CGRectMake(
				42.0f, 10.0f, aRect.size.width - 4.0f, aRect.size.width - 4.0f));
	
	CGContextMoveToPoint(theContext, aRect.size.width / 2.0f - 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f - 5.0f);
	CGContextAddLineToPoint(theContext, aRect.size.width / 2.0f + 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f + 5.0f);
	CGContextMoveToPoint(theContext, aRect.size.width / 2.0f + 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f - 5.0f);
	CGContextAddLineToPoint(theContext, aRect.size.width / 2.0f - 5.0f + aRect.origin.x,
				aRect.size.height / 2.0f + 5.0f);
	
	CGContextSetStrokeColorWithColor(theContext, (
				self.isHighlighted ? [UIColor darkGrayColor].CGColor : [UIColor whiteColor].CGColor));
	CGContextStrokePath(theContext);
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
	self.closeLabel.textColor = highlighted ? [UIColor darkGrayColor] : [UIColor whiteColor];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (nil == self.closeLabel)
	{
		self.closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(
					0.0f, 0.0f, 40.0f, self.frame.size.height)];
		self.closeLabel.textColor = [UIColor whiteColor];
		self.closeLabel.backgroundColor = [UIColor clearColor];
		self.closeLabel.font = [UIFont systemFontOfSize:12.0f];
		self.closeLabel.text = @"Close";
		[self addSubview:self.closeLabel];
	}
}

@end
