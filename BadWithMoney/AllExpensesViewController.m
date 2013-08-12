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

@interface AllExpensesViewController ()

@end

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AllExpenseViewToExpenseView"]){
		ExpenseViewController *expenseViewController = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		Expense *expense = [sortedExpenses objectAtIndex:indexPath.row];
		expenseViewController.expense = expense;
		expenseViewController.isNew = @NO;
	}
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self refreshExpenses];
}

-(void) refreshExpenses {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	sortedExpenses = [[[ExpenseStore sharedStore] allExpenses] sortedArrayUsingDescriptors:sortDescriptors];
	[self.tableView reloadData];
}

-(IBAction)unwindSegueToAllExpenseView: (UIStoryboardSegue *) segue{
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[ExpenseStore sharedStore] allExpenses] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ExpenseCell";
    ExpenseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	Expense *expense = [sortedExpenses objectAtIndex: indexPath.row];
	
    cell.nameLabel.text = expense.name;
	cell.valueLabel.text = [nf stringFromNumber:expense.value];
	cell.categoryLabel.text = expense.category.name;
	cell.dateLabel.text = [df stringFromDate:expense.date];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
