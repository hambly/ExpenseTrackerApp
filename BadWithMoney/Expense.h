//
//  Expense.h
//  BadWithMoney
//
//  Created by Mark on 8/6/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface Expense : NSManagedObject

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * orderingValue;
@property (nonatomic, retain) Category *category;

@end
