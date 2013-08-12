//
//  Category.h
//  BadWithMoney
//
//  Created by Mark on 8/6/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Expense;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderingValue;
@property (nonatomic, retain) NSSet *expenseSet;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addExpenseSetObject:(Expense *)value;
- (void)removeExpenseSetObject:(Expense *)value;
- (void)addExpenseSet:(NSSet *)values;
- (void)removeExpenseSet:(NSSet *)values;

@end
