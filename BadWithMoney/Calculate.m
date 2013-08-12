//
//  Calculate.m
//  BadWithMoney
//
//  Created by Mark on 8/9/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import "Calculate.h"
#import "Expense.h"
#import "Category.h"
#import "ExpenseStore.h"

@implementation Calculate

+(NSArray *) listOfExpenseNamesSimilarTo: (Expense *)expense{
	NSArray *allExpensesInCategory = [[ExpenseStore sharedStore] allExpensesInCategory:expense.category];
	NSMutableDictionary *similarExpenseNames = [NSMutableDictionary dictionary];
	for (Expense *exp in allExpensesInCategory){
		if (exp.name){
			[similarExpenseNames setObject:exp.name forKey:[NSString stringWithFormat:@"%@",exp.name]];
		}
	}
	return [similarExpenseNames allKeys];
}



@end
