//
//  FakeExpense.m
//  BadWithMoney
//
//  Created by Mark on 8/6/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import "FakeExpense.h"
#import "ExpenseStore.h"
#import "Expense.h"
#import "Category.h"

@implementation FakeExpense {

}

+(NSMutableArray *) generateRandomExpenses: (int)numberOfExpenses
{
	NSMutableArray *expenseArray = [[NSMutableArray alloc] init];
	for (int i = 0; i < numberOfExpenses; i++){
		Expense *newExpense = [self generateRandomExpense];
		[expenseArray addObject:newExpense];
	}
	return expenseArray;
	
}

+(Expense *) generateRandomExpense
{
	Expense *newExpense = [[ExpenseStore sharedStore] createExpense];
	NSArray *names = @[@"Toyota Corolla",
					@"Gibson Les Paul",
					@"Subway",
					@"Whole Foods",
					@"Rent",
					@"Beer",
					@"Dinner out",
					@"Concert ticket",
					@"AT&T",
					@"Secret"];
	NSArray *values = @[@24000,
					 @2400,
					 @9,
					 @78,
					 @1825,
					 @35,
					 @65,
					 @90,
					 @97,
					 @2];
	NSArray *dates = @[[NSDate dateWithTimeInterval:-10*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-8*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-7*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-6*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-5*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-4*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-20*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-15*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-12*24*60*60 sinceDate:[NSDate date]],
					[NSDate dateWithTimeInterval:-1*24*60*60 sinceDate:[NSDate date]],];
	NSArray *categories = [self returnCategories];
	
	int r = arc4random_uniform(names.count);
	newExpense.name = names[r];
	
	r = arc4random_uniform(values.count);
	newExpense.value = values[r];
	
	r = arc4random_uniform(dates.count);
	newExpense.date = dates[r];
	
	r= arc4random_uniform(categories.count);
	newExpense.category = categories[r];
	
	//	NSLog(@"Created Expense for %@, %i, on %@, in category: %@",newExpense.name, newExpense.value.intValue, newExpense.date, newExpense.category);
	
	return newExpense;
}

+(NSArray *) returnCategories
{
	
	if ([[[ExpenseStore sharedStore] allCategories] count] == 0)
	{
		NSArray *categories = @[@"Groceries",
						  @"Rent",
						  @"Utilities",
						  @"Joy",
						  @"Tech",
						  @"Miscellaneous"];
		for (int i = 0; i < categories.count; i++){
			Category *category = [[ExpenseStore sharedStore] createCategory];
			category.name = categories[i];
		}
	}
	return [[ExpenseStore sharedStore] allCategories];

}

@end
