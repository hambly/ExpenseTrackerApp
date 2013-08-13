//
//  ExpenseStore.m
//  BadWithMoney
//
//  Created by Mark on 8/6/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import "ExpenseStore.h"
#import "Expense.h"
#import "Category.h"

@implementation ExpenseStore {
	NSMutableArray *allExpenses;
	NSManagedObjectContext *context;
	NSManagedObjectModel *model;
	NSMutableArray *allCategories;
}

+(ExpenseStore *) sharedStore
{
	static ExpenseStore *sharedStore = nil;
	
	if (!sharedStore)
	{
		sharedStore = [[super allocWithZone:nil] init];
	}
	
	return sharedStore;
	
}

+(id) allocWithZone:(NSZone *)zone
{
	return [self sharedStore];
}

-(id) init
{
	self = [super init];

	if (self)
	{
		
		model = [NSManagedObjectModel mergedModelFromBundles:nil];
		NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
		
		NSError *error = nil;
		NSString *storePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		storePath = [storePath stringByAppendingPathComponent:@"expensestore.sqlite"];
		NSURL *storeURL = [NSURL fileURLWithPath:storePath];
		
		NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
									NSInferMappingModelAutomaticallyOption: @YES};
		
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
													  configuration:nil
																URL:storeURL
															options:options
															  error:&error])
		{
			[NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
		}
		
		context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:persistentStoreCoordinator];
		[context setUndoManager:nil];
		
		[self loadAllExpenses];
		[self loadAllCategories];
		
	}
	
	return self;
}

-(void)saveChanges
{
	NSError *error = nil;
	BOOL success = [context save:&error];
	if (!success){
		NSLog(@"Error saving: %@", [error localizedDescription]);
	} else {
//		NSLog(@"Save complete!");
	}
}

-(Expense *) createExpense
{
	double order = 0.0;
	if (allExpenses.count == 0)
	{
		order = 1.0;
	} else {
		order = [[[allExpenses lastObject] orderingValue] doubleValue] +1.0;
	}
	
	Expense *expense= [NSEntityDescription insertNewObjectForEntityForName:@"Expense"
											  inManagedObjectContext:context];
	expense.orderingValue = [NSNumber numberWithDouble:order];
	expense.date = [NSDate date];
	
	[allExpenses addObject:expense];

	return expense;
}

-(void) removeExpense:(Expense *)expense
{
	[context deleteObject:expense];
	[allExpenses removeObjectIdenticalTo:expense];
//	NSLog(@"%@ expense deleted",expense.name);
}

-(NSArray *) allExpenses
{
	return allExpenses;
}

-(void) loadAllExpenses
{
	if (!allExpenses)
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entityDescription = [[model entitiesByName] objectForKey:@"Expense"];
		[request setEntity:entityDescription];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		NSError *error;
		NSArray *result = [context executeFetchRequest:request
												 error:&error];
		if (!result)
		{
			[NSException raise:@"Fetch failed" format:@"Reason: %@", error.localizedDescription];
		}
		
		allExpenses = [[NSMutableArray alloc] initWithArray:result];
	}
}

-(NSArray *) allExpensesInCategory: (Category *) category{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@",category];
	[request setPredicate:predicate];
	
	NSEntityDescription *entityDescription = [[model entitiesByName] objectForKey:@"Expense"];
	[request setEntity:entityDescription];
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	NSArray *result = [context executeFetchRequest:request
											 error:&error];
	if (!result)
	{
		[NSException raise:@"Fetch failed" format:@"Reason: %@", error.localizedDescription];
	}
	
	return result;
	
}


#pragma mark - Category Methods

-(Category *) createCategory
{
	double order = 0.0;
	if (allCategories.count == 0)
	{
		order = 1.0;
	} else {
		order = [[[allCategories lastObject] orderingValue] doubleValue] +1.0;
	}
	
	Category *category= [NSEntityDescription insertNewObjectForEntityForName:@"Category"
													inManagedObjectContext:context];
	category.orderingValue = [NSNumber numberWithDouble:order];
	
	[allCategories addObject:category];
	
	return category;
}

-(void) removeCategory:(Category *)category
{
	[context deleteObject:category];
	[allCategories removeObjectIdenticalTo:category];
//	NSLog(@"%@ category deleted",category.name);
}

-(NSArray *) allCategories
{
	return allCategories;
}

-(void) loadAllCategories
{
	if (!allCategories)
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entityDescription = [[model entitiesByName] objectForKey:@"Category"];
		[request setEntity:entityDescription];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		NSError *error;
		NSArray *result = [context executeFetchRequest:request
												 error:&error];
		if (!result)
		{
			[NSException raise:@"Fetch failed" format:@"Reason: %@", error.localizedDescription];
		}
		
		allCategories = [[NSMutableArray alloc] initWithArray:result];
	}
}

-(void) moveCategoryAtIndex: (int)fromIndex toIndex: (int) toIndex
{
	if (fromIndex == toIndex)
		return;
	
	Category *category = [allCategories objectAtIndex:fromIndex];
	[allCategories removeObjectAtIndex:fromIndex];
	[allCategories insertObject:category atIndex:toIndex];
	
	// Recalculate ordering value
	
	double lowerBound = 0.0;
	if (toIndex > 0){
		lowerBound = [[[allCategories objectAtIndex: toIndex - 1] orderingValue] doubleValue];
	} else {
		lowerBound = [[[allCategories objectAtIndex: 1] orderingValue] doubleValue] - 2.0;
	}
	
	double upperBound = 0.0;
	if (toIndex < allCategories.count - 1 ){
		upperBound = [[[allCategories objectAtIndex:toIndex +1] orderingValue] doubleValue];
	} else {
		upperBound = [[[allCategories objectAtIndex:toIndex -1] orderingValue] doubleValue] +2.0;
	}
	
	double newOrderValue = (lowerBound + upperBound) / 2.0;
	
	category.orderingValue = [NSNumber numberWithDouble:newOrderValue];
	
}




@end
