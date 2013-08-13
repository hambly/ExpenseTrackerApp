//
//  AllExpensesViewController.m
//  BadWithMoney
//
//  Created by Mark on 8/8/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import "AllExpensesViewController.h"
#import "ExpenseViewController.h"
#import "ExpenseStore.h"
#import "Expense.h"
#import "ExpenseTableViewCell.h"
#import "Category.h"	

@implementation AllExpensesViewController {
	NSNumberFormatter *nf;
	NSDateFormatter *df;
	NSArray *sortedExpenses;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		sortedExpenses = [[[ExpenseStore sharedStore] allExpenses] sortedArrayUsingDescriptors:sortDescriptors];
		
		
		nf = [[NSNumberFormatter alloc] init];
		[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
		[nf setCurrencySymbol:@"$"];
		[nf setMaximumFractionDigits:0];
		
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"MMM d, YYYY"];
    }
    return self;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AllExpenseViewToExpenseView"]){
		ExpenseViewController *expenseViewController = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		Expense *expense;
		if (self.filteredExpenses != nil){
			expense = [self.filteredExpenses objectAtIndex:indexPath.row];
		} else {
			expense = [sortedExpenses objectAtIndex:indexPath.row];
		}
		
		expenseViewController.expense = expense;
		expenseViewController.isNew = @NO;
	}
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self refreshExpenses];
}

-(void) refreshExpenses {
	if (self.filteredExpenses == nil){
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		sortedExpenses = [[[ExpenseStore sharedStore] allExpenses] sortedArrayUsingDescriptors:sortDescriptors];
	}
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.filteredExpenses != nil)
		return self.filteredExpenses.count;
	else
		return sortedExpenses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ExpenseCell";
    ExpenseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Expense *expense;
	
	if (self.filteredExpenses != nil){
		expense = [self.filteredExpenses objectAtIndex: indexPath.row];
	} else {
		expense = [sortedExpenses objectAtIndex: indexPath.row];
	}
	
    cell.nameLabel.text = expense.name;
	cell.valueLabel.text = [nf stringFromNumber:expense.value];
	cell.categoryLabel.text = expense.category.name;
	cell.dateLabel.text = [df stringFromDate:expense.date];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}


@end
