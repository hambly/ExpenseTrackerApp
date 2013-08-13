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
#define PADDING 10

@interface MHLabel()

@property (nonatomic, strong) NSNumber *isSelected;
@property (nonatomic, strong) NSNumber *isTitleLabel;

@end

@implementation MHLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
		self.isSelected = @NO;
		self.isTitleLabel = @NO;
		
		self.font = [UIFont fontWithName:@"Avenir Next" size:FAVORITEFONTSIZE];
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

-(void) setText:(NSString *)text{
	[super setText:text];
	[self sizeToFit];
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + PADDING, self.frame.size.height)];
}

-(void) selectLabel{
	self.isSelected = @YES;
	self.backgroundColor = [UIColor lightGrayColor];

}

-(void) makeTitleLabel {
	self.isTitleLabel = @YES;
	self.backgroundColor = [UIColor clearColor];
	self.layer.borderWidth = 0.0;
	self.userInteractionEnabled = NO;
}


@end
