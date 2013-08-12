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



@interface ExpenseViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@end

@implementation ExpenseViewController {
	NSMutableArray *_labels;
	Category *_categorySelected;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	_labels = [NSMutableArray array];
	
}

#pragma mark - Fun With labels

-(void) addLabelForName: (NSString *)name {
	MHLabel *label = [[MHLabel alloc] initWithFrame:CGRectZero];
	
	label.text = name;
	
	[label sizeToFit];
	[label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width + 10.0, label.frame.size.height)];
	[label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)]];
	
	[_labels addObject:label];
	if ([self.isNew isEqual:@YES] && _labels.count == 1){
		label.backgroundColor = [UIColor clearColor];
		label.layer.borderWidth = 0.0;
		label.userInteractionEnabled = NO;
	}
	[self.scrollView addSubview:label];
}

-(void) addLabelForCategory: (Category *)category {
	MHLabel *label = [[MHLabel alloc] initWithFrame:CGRectZero];
	
	label.text = category.name;
	
	[label sizeToFit];
	[label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width + 10.0, label.frame.size.height)];
	[label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)]];
	
	if (category == _categorySelected) {
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
	
	if ([self.isNew isEqual: @YES]){
		NSArray *names = [Calculate listOfExpenseNamesSimilarTo:self.expense];
		if (names.count > 0){
			[self addLabelForName:@"May I Suggest:"];
		} else {
			[self addLabelForName:@""];
		}
		for (int i = 0; i < names.count; i++){
			[self addLabelForName:names[i]];
		}
	} else {
		NSArray *categories = [[ExpenseStore sharedStore] allCategories];
		for (int i = 0; i < categories.count; i++){
			Category *category = [categories objectAtIndex:i];
			[self addLabelForCategory:category];
	}
	
	
	}
	
}

-(void) refreshLayout {
	
	[MHLabel adjustLabelFrames:_labels forScrollView:self.scrollView];

}


-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshLabels];
	[self refreshLayout];
	
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


- (IBAction)saveButtonPressed:(id)sender {
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
		[self performSegueWithIdentifier:@"UnwindSegueFromExpenseViewToAllExpensesView" sender:self];
	}
}

- (IBAction)cancelButtonPressed:(id)sender {
	if (self.isNew.boolValue){
		[[ExpenseStore sharedStore] removeExpense:self.expense];
		[self performSegueWithIdentifier:@"UnwindSegueFromExpenseViewToMainView" sender:self];
	} else {
		[self performSegueWithIdentifier:@"UnwindSegueFromExpenseViewToAllExpensesView" sender:self];
	}
	
}

@end