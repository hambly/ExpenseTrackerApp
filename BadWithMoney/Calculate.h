//
//  Calculate.h
//  BadWithMoney
//
//  Created by Mark on 8/9/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Expense;
@class Category;

@interface Calculate : NSObject

+(NSArray *) listOfExpenseNamesSimilarTo: (Expense *)expense;
+(NSDictionary *) listOfMonthsWithExpenses;
+(NSArray *) listOfCostRanges;
+(NSArray *) temporaryCostRanges;


@end
