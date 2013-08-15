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

@interface ExpenseStore ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

@end

@implementation ExpenseStore {
	NSMutableArray *_allExpenses;
	NSMutableArray *_allCategories;
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
		
		_model = [NSManagedObjectModel mergedModelFromBundles:nil];
		NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
		
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
		
		_context = [[NSManagedObjectContext alloc] init];
		[_context setPersistentStoreCoordinator:persistentStoreCoordinator];
		[_context setUndoManager:nil];
		
		[self loadAllExpenses];
		[self loadAllCategories];
		
	}
	
	return self;
}

-(void)saveChanges
{
	NSError *error = nil;
	BOOL success = [self.context save:&error];
	if (!success){
		NSLog(@"Error saving: %@", [error localizedDescription]);
	} else {
//		NSLog(@"Save complete!");
	}
}

-(Expense *) createExpense
{
	double order = 0.0;
	if (_allExpenses.count == 0)
	{
		order = 1.0;
	} else {
		order = [[[_allExpenses lastObject] orderingValue] doubleValue] +1.0;
	}
	
	Expense *expense= [NSEntityDescription insertNewObjectForEntityForName:@"Expense"
											  inManagedObjectContext:self.context];
	expense.orderingValue = [NSNumber numberWithDouble:order];
	expense.date = [NSDate date];
	
	[_allExpenses addObject:expense];

	return expense;
}

-(void) removeExpense:(Expense *)expense
{
	[self.context deleteObject:expense];
	[_allExpenses removeObjectIdenticalTo:expense];
//	NSLog(@"%@ expense deleted",expense.name);
}

-(NSArray *) allExpenses
{
	return _allExpenses;
}

-(void) loadAllExpenses
{
	if (!_allExpenses)
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entityDescription = [[self.model entitiesByName] objectForKey:@"Expense"];
		[request setEntity:entityDescription];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		NSError *error;
		NSArray *result = [self.context executeFetchRequest:request
												 error:&error];
		if (!result)
		{
			[NSException raise:@"Fetch failed" format:@"Reason: %@", error.localizedDescription];
		}
		
		_allExpenses = [[NSMutableArray alloc] initWithArray:result];
	}
}

-(NSArray *) allExpensesInCategory: (Category *) category{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@",category];
	[request setPredicate:predicate];
	
	NSEntityDescription *entityDescription = [[self.model entitiesByName] objectForKey:@"Expense"];
	[request setEntity:entityDescription];
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	NSArray *result = [self.context executeFetchRequest:request
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
	if (_allCategories.count == 0)
	{
		order = 1.0;
	} else {
		order = [[[_allCategories lastObject] orderingValue] doubleValue] +1.0;
	}
	
	Category *category= [NSEntityDescription insertNewObjectForEntityForName:@"Category"
													inManagedObjectContext:self.context];
	category.orderingValue = [NSNumber numberWithDouble:order];
	
	[_allCategories addObject:category];
	
	return category;
}

-(void) removeCategory:(Category *)category
{
	[self.context deleteObject:category];
	[_allCategories removeObjectIdenticalTo:category];
//	NSLog(@"%@ category deleted",category.name);
}

-(NSArray *) allCategories
{
	return _allCategories;
}

-(void) loadAllCategories
{
	if (!_allCategories)
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entityDescription = [[self.model entitiesByName] objectForKey:@"Category"];
		[request setEntity:entityDescription];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		NSError *error;
		NSArray *result = [self.context executeFetchRequest:request
												 error:&error];
		if (!result)
		{
			[NSException raise:@"Fetch failed" format:@"Reason: %@", error.localizedDescription];
		}
		
		_allCategories = [[NSMutableArray alloc] initWithArray:result];
	}
}

-(void) moveCategoryAtIndex: (int)fromIndex toIndex: (int) toIndex
{
	if (fromIndex == toIndex)
		return;
	
	Category *category = [_allCategories objectAtIndex:fromIndex];
	[_allCategories removeObjectAtIndex:fromIndex];
	[_allCategories insertObject:category atIndex:toIndex];
	
	// Recalculate ordering value
	
	double lowerBound = 0.0;
	if (toIndex > 0){
		lowerBound = [[[_allCategories objectAtIndex: toIndex - 1] orderingValue] doubleValue];
	} else {
		lowerBound = [[[_allCategories objectAtIndex: 1] orderingValue] doubleValue] - 2.0;
	}
	
	double upperBound = 0.0;
	if (toIndex < _allCategories.count - 1 ){
		upperBound = [[[_allCategories objectAtIndex:toIndex +1] orderingValue] doubleValue];
	} else {
		upperBound = [[[_allCategories objectAtIndex:toIndex -1] orderingValue] doubleValue] +2.0;
	}
	
	double newOrderValue = (lowerBound + upperBound) / 2.0;
	
	category.orderingValue = [NSNumber numberWithDouble:newOrderValue];
	
}




@end
