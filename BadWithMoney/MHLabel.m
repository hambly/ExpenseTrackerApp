//
//  MHLabel.m
//  BadWithMoney
//
//  Created by Mark on 8/8/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MHLabel.h"

#define MARGIN 8
#define FAVORITEFONTSIZE 22

@implementation MHLabel

+(void) adjustLabelFrames: (NSMutableArray*) labelsArray forScrollView: (UIScrollView *) scrollView {
	
	float currentX = 0 + MARGIN;
	float currentY = 0 + MARGIN;
	float maxY = 0;
	
	for (MHLabel *label in labelsArray) {
		if (currentX + label.frame.size.width > scrollView.bounds.size.width - MARGIN) {
			currentX = 0 + MARGIN;
			currentY = maxY + MARGIN;
			maxY = currentY;
		}
		
		CGRect frame = label.frame;
		frame.origin.x = currentX;
		frame.origin.y = currentY;
		label.frame = frame;
		
		currentX += frame.size.width + MARGIN;
		maxY = MAX(maxY, currentY + frame.size.height);
	}
	
	scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, maxY + MARGIN);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.font = [UIFont fontWithName:@"Avenir Next" size:22];
		self.textColor = [UIColor blackColor];
		self.layer.borderWidth = 2.0;
		self.layer.borderColor = [UIColor blackColor].CGColor;
		self.layer.shadowColor = [UIColor grayColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(10, 10);
		self.userInteractionEnabled = YES;
		self.textAlignment = NSTextAlignmentCenter;
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
