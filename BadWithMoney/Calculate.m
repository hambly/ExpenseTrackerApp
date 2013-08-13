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


+(NSDictionary *) listOfMonthsWithExpenses{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *expensesOrderedByDate = [[[ExpenseStore sharedStore] allExpenses] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	NSMutableDictionary *monthNames = [NSMutableDictionary dictionary];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MMM/YY"];
	for (Expense *exp in expensesOrderedByDate){
		if (exp.date){
			[monthNames setObject:exp.date forKey:[df stringFromDate:exp.date]];
		}
	}
	
	return monthNames;
	
}



+(NSArray *) temporaryCostRanges {
	NSArray *costRanges = @[@1,@20,@50,@100,@500];
	return costRanges;
}


// This is not used, cost ranges are not calculated
+(NSArray *) listOfCostRanges {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
	NSArray *expensesOrderedByValue = [[[ExpenseStore sharedStore] allExpenses] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	Expense *minExpense = expensesOrderedByValue[0];
	Expense *maxExpense = [expensesOrderedByValue lastObject];
	int min = [self roundThisNumberPlease:minExpense.value.intValue roundUp:NO];
	int max = [self roundThisNumberPlease:maxExpense.value.intValue roundUp:YES];
	
	int half = [self roundThisNumberPlease:max-min roundUp:NO];
	int lowQuarter = [self roundThisNumberPlease:half-min roundUp:NO];
	int highQuarter = [self roundThisNumberPlease:max-half roundUp:NO];
	
	NSArray *list = @[[NSNumber numberWithInt:min],
					 [NSNumber numberWithInt:lowQuarter], [NSNumber numberWithInt:half],
				   [NSNumber numberWithInt:highQuarter], [NSNumber numberWithInt:max]];
	return list;
}

+(int) roundThisNumberPlease: (int) num roundUp: (BOOL) directionUp {
	
	if (num < 10){
		return 1;
	}
	
	for (int i = 10; i < num; i*=10){
		if (num % i != 0) {
			if (directionUp){
				num = num + i - (num % i);
			} else {
				num = num - (num % i);
			}
		}
	}
	return num;
}
//

@end
