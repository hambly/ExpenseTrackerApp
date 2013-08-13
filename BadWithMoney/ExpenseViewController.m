//
//  ExpenseViewController.m
//  BadWithMoney
//
//  Created by Mark on 8/8/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ExpenseViewController.h"
#import "Expense.h"
#import	"ExpenseStore.h"
#import	"Category.h"
#import "MHLabel.h"
#import "Calculate.h"

@interface ExpenseViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation ExpenseViewController {
	NSMutableArray *_labels;
	Category *_categorySelected;	
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	_labels = [NSMutableArray array];
	
	UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
	rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[rightSwipeRecognizer setNumberOfTouchesRequired:1];
	[self.view addGestureRecognizer:rightSwipeRecognizer];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.nameField becomeFirstResponder];
	
	NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MMM d, YYYY"];
	
	self.nameField.text = self.expense.name;
	self.valueField.text = [nf stringFromNumber:self.expense.value];
	self.dateLabel.text = [df stringFromDate:self.expense.date];
	_categorySelected = self.expense.category;
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshLabels];
	[self refreshLayout];
}

#pragma mark - Fun With labels

-(void) addLabelForString: (NSString *)string {
	MHLabel *label = [[MHLabel alloc] initWithFrame:CGRectZero];
	label.text = string;
	
	[label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)]];
	[_labels addObject:label];

	if ([self.isNew isEqual:@YES] && _labels.count == 1){
		[label makeTitleLabel];
	} else if ([string isEqualToString:_categorySelected.name]){
		[label selectLabel];
	}
	[self.scrollView addSubview:label];
}

-(void)refreshLabels {
	for (int i = _labels.count -1; i >= 0; --i){
		MHLabel *label = [_labels objectAtIndex:i];
		[label removeFromSuperview];
		[_labels removeObjectAtIndex:i];
	}
	
	if ([self.isNew isEqual: @YES]){
		NSArray *names = [Calculate listOfExpenseNamesSimilarTo:self.expense];
		[self addLabelForString:[NSString stringWithFormat:@"%s", (names.count>0) ? "May I Suggest:":""]];
		for (int i = 0; i < names.count; i++){
			[self addLabelForString:names[i]];
		}
	} else {
		NSArray *categories = [[ExpenseStore sharedStore] allCategories];
		for (int i = 0; i < categories.count; i++){
			Category *category = [categories objectAtIndex:i];
			[self addLabelForString:category.name];
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

-(void) labelTapped: (UITapGestureRecognizer *)recognizer {
	MHLabel *label = (MHLabel *) recognizer.view;
	
	if ([self.isNew isEqual:@YES]){
		self.nameField.text = label.text;
	} else {
		Category *category = [[[ExpenseStore sharedStore] allCategories] objectAtIndex:[_labels indexOfObject:label]];
		self.expense.category = category;
		_categorySelected = category;
	}
	[self refreshLabels];
	[self refreshLayout];
}

#pragma mark - Nav Buttons Pressed

- (IBAction)backButtonPressed:(id)sender {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
	self.expense.name = self.nameField.text;
	if ([self.expense.name isEqualToString:@""]){
		self.expense.name = @"Misc. Expense";
	}
	self.expense.value = [nf numberFromString:self.valueField.text];
	if (self.expense.value == nil){
		self.expense.value = @0;
	}
	[[ExpenseStore sharedStore] saveChanges];
	
	if ([self.isNew isEqual:@YES]){
		[self performSegueWithIdentifier:@"UnwindSegueFromExpenseViewToMainView" sender:self];
	} else {
		[self performSegueWithIdentifier:@"UnwindSegueFromExpenseViewToSortView" sender:self];
	}
}
- (IBAction)deleteButtonPressed:(id)sender {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													message:@"Confirm Delete"
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Delete", nil];
	[alert show];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1){
		if (self.isNew.boolValue){
			[[ExpenseStore sharedStore] removeExpense:self.expense];
			[self performSegueWithIdentifier:@"UnwindSegueFromExpenseViewToMainView" sender:self];
		} else {
			[[ExpenseStore sharedStore] removeExpense:self.expense];
			[self performSegueWithIdentifier:@"UnwindSegueFromExpenseViewToSortView" sender:self];
		}
	}
}

-(IBAction)didSwipeRight:(id)sender {
	[self backButtonPressed:sender];
}

@end