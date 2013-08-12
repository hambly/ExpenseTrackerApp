//
//  ExpenseStore.h
//  BadWithMoney
//
//  Created by Mark on 8/6/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Expense;
@class Category;

@interface ExpenseStore : NSObject

+(ExpenseStore *) sharedStore;
-(void)saveChanges;

-(NSArray *) allExpenses;
-(void) loadAllExpenses;
-(Expense *)createExpense;
-(void) removeExpense: (Expense *)expense;
-(NSArray *) allExpensesInCategory: (Category *) category;

-(NSArray *) allCategories;
-(void) loadAllCategories;
-(Category *) createCategory;
-(void) removeCategory: (Category *)category;
-(void) moveCategoryAtIndex: (int)fromIndex toIndex: (int) toIndex;

@end
