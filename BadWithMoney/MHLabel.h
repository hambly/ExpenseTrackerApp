//
//  MHLabel.h
//  BadWithMoney
//
//  Created by Mark on 8/8/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHLabel : UILabel

+(void) adjustLabelFrames: (NSMutableArray*) labelsArray forScrollView: (UIScrollView *) scrollView;

-(void)selectLabel;
-(void)makeTitleLabel;

@end
