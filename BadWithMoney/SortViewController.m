//
//  SortViewController.m
//  BadWithMoney
//
//  Created by Mark on 8/12/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import "SortViewController.h"
#import "AllExpensesViewController.h"
#import "ExpenseStore.h"
#import "Expense.h"
#import "Category.h"	
#import "MHLabel.h"
#import "Calculate.h"


@interface SortViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) AllExpensesViewController *allExpenseViewController;

@end

@implementation SortViewController{
	NSMutableArray *_labels;
	NSString *_filterSelected;
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	_labels = [NSMutableArray array];
	[self.filterSegmentedControl setSelectedSegmentIndex:0];
		
	if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
		self.automaticallyAdjustsScrollViewInsets = NO;
	}

	
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshLabels];
	[self refreshLayout];
	[self.allExpenseViewController.tableView reloadData];
	
}

#pragma mark - Storyboard Segue Methods

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"SortViewEmbedExpenseTableView"]){
		self.allExpenseViewController = segue.destinationViewController;
	}
}

#pragma mark - Fun With labels

-(void) addLabelForString: (NSString *) string{
	MHLabel *label = [[MHLabel alloc] initWithFrame:CGRectZero];
	label.text = string;
	
	[label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)]];
	if ([label.text isEqualToString:_filterSelected]){
		label.backgroundColor = [UIColor lightGrayColor];
	}
	[_labels addObject:label];
	[self.scrollView addSubview:label];
}

-(void)refreshLabels {
	for (int i = _labels.count -1; i >= 0; --i){
		MHLabel *label = [_labels objectAtIndex:i];
		[label removeFromSuperview];
		[_labels removeObjectAtIndex:i];
	}
	
	if ([self.filterSegmentedControl selectedSegmentIndex] == 0){
		NSArray *categories = [[ExpenseStore sharedStore] allCategories];
		for (int i = 0; i < categories.count; i++){
			Category *category = [categories objectAtIndex:i];
			[self addLabelForString:category.name];
		}
	} else if ([self.filterSegmentedControl selectedSegmentIndex] == 1){
		NSArray *monthNames = [[Calculate listOfMonthsWithExpenses] allKeys];
		for (int i = 0; i < monthNames.count; i++){
			[self addLabelForString:monthNames[i]];
		}
	} else if ([self.filterSegmentedControl selectedSegmentIndex] == 2){
		NSArray *costRanges = [Calculate temporaryCostRanges];
		NSNumberFormatter *nf = [NSNumberFormatter new];
		[nf setCurrencySymbol:@"$"];
		[nf setMaximumFractionDigits:0];
		[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
		for (int i = 0; i < costRanges.count; i++){
			NSString *costRangeString;
			if (i == costRanges.count-1){
				costRangeString = [NSString stringWithFormat:@"%@+",[nf stringFromNumber:costRanges[i]]];
			} else {
				costRangeString = [NSString stringWithFormat:@"%@-%@",[nf stringFromNumber:costRanges[i]],[nf stringFromNumber:costRanges[i+1]]];
			}
			[self addLabelForString:costRangeString];
		}
	}
}

-(void) refreshLayout {
	[MHLabel adjustLabelFrames:_labels forScrollView:self.scrollView];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[UIView animateWithDuration:0.25 animations:^{
		[self refreshLayout];
	}];
}

#pragma mark - Expense Filtering Methods

-(void)labelTapped: (UITapGestureRecognizer *)recognizer{
	MHLabel *labelSelected = (MHLabel *)recognizer.view;
	_filterSelected = labelSelected.text;
	NSPredicate *predicate;

	if ([self.filterSegmentedControl selectedSegmentIndex] == 0){
		// Filter by category
		predicate = [NSPredicate predicateWithFormat:@"category.name like %@",labelSelected.text];
				
	} else 	if ([self.filterSegmentedControl selectedSegmentIndex] == 1){
		//Filter by Date Range
		NSDictionary *monthsDictionary = [Calculate listOfMonthsWithExpenses];
		NSDate *dateSelected = [monthsDictionary objectForKey:labelSelected.text];
		
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:dateSelected];
		
		NSDate *startDate = [calendar dateFromComponents:components];
		[components setMonth:1];
		[components setDay:0];
		[components setYear:0];
		NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
		
		predicate = [NSPredicate predicateWithFormat:@"((date >= %@) AND (date < %@)) || (date = nil)",startDate,endDate];

	} else if ([self.filterSegmentedControl selectedSegmentIndex] == 2){
		// Filter By Cost Range
		NSArray *costRanges = [Calculate temporaryCostRanges];
		int index = [_labels indexOfObject:labelSelected];
		
		if (index == _labels.count-1){
			predicate = [NSPredicate predicateWithFormat:@"value >= %@",costRanges[index]];
		} else {
			predicate = [NSPredicate predicateWithFormat:@"(value >= %@) AND (value < %@)",costRanges[index],costRanges[index+1]];
		}
	}
	
	NSArray *allExpenses = [[ExpenseStore sharedStore] allExpenses];
	NSArray *filteredArray = [allExpenses filteredArrayUsingPredicate:predicate];
	[self refreshTableViewWithExpenses:filteredArray];
	
}

- (IBAction)filterSegmentedControlValueChanged:(id)sender {
	
	_filterSelected = nil;
	
	NSArray *sortDescriptors;
	
	if ([self.filterSegmentedControl selectedSegmentIndex] == 0){
		NSSortDescriptor *sortDescriptorCategory = [NSSortDescriptor sortDescriptorWithKey:@"category.orderingValue" ascending:YES];
		NSSortDescriptor *sortDescriptorDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
		sortDescriptors = [NSArray arrayWithObjects:sortDescriptorCategory,sortDescriptorDate, nil];

		NSArray *allExpenses = [[ExpenseStore sharedStore] allExpenses];
		NSArray *expensesSortedByCategoryThenDate = [allExpenses sortedArrayUsingDescriptors:sortDescriptors];
		
		[self refreshTableViewWithExpenses:expensesSortedByCategoryThenDate];
		
		
	} else if ([self.filterSegmentedControl selectedSegmentIndex] == 1){
		NSSortDescriptor *sortDescriptorDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
		sortDescriptors = [NSArray arrayWithObjects:sortDescriptorDate, nil];
		
	} else if ([self.filterSegmentedControl selectedSegmentIndex] == 2){
		NSSortDescriptor *sortDescriptorCost = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO];
		sortDescriptors = [NSArray arrayWithObject:sortDescriptorCost];
	}
	
	NSArray *allExpenses = [[ExpenseStore sharedStore] allExpenses];
	NSArray *sortedExpenses = [allExpenses sortedArrayUsingDescriptors:sortDescriptors];
	[self refreshTableViewWithExpenses: sortedExpenses];
	
}

-(void) refreshTableViewWithExpenses: (NSArray*)expenseArray{
	
	self.allExpenseViewController.filteredExpenses = expenseArray;
	
	[self refreshLabels];
	[self refreshLayout];
	
	[self.allExpenseViewController.tableView reloadData];
}

#pragma mark - Unwind Segues

-(IBAction)unwindSegueToSortView: (UIStoryboardSegue *) segue{
	
}

@end
