//
//  FakeExpense.h
//  BadWithMoney
//
//  Created by Mark on 8/6/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Expense;

@interface FakeExpense : NSObject

+(NSMutableArray *) generateRandomExpenses: (int)numberOfExpenses;
+(Expense *) generateRandomExpense;


@end
