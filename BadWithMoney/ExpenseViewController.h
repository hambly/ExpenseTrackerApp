//
//  ExpenseViewController.h
//  BadWithMoney
//
//  Created by Mark on 8/8/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Expense;


@interface ExpenseViewController : UIViewController
@property (nonatomic, strong) NSNumber *isNew;
@property (nonatomic, strong) Expense *expense;

@end
