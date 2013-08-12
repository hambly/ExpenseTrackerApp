//
//  MainViewController.m
//  BadWithMoney
//
//  Created by Mark on 8/8/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainViewController.h"
#import "ExpenseStore.h"
#import "Expense.h"
#import "Category.h"
#import "FakeExpense.h"
#import "ExpenseViewController.h"
#import "MHLabel.h"


@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@end

@implementation MainViewController {
	NSMutableArray *_labels;
	Category *_categorySelected;
	NSNumber *_isMenuVisible;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
//		[self.navigationController setNavigationBarHidden:YES];
		
		if ([[[ExpenseStore sharedStore] allExpenses] count] == 0){
			[FakeExpense generateRandomExpenses:10];
			
		}
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"MainViewToNewExpenseView"]){
		ExpenseViewController *expenseViewController = segue.destinationViewController;
		Expense *newExpense = [[ExpenseStore sharedStore] createExpense];
		NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
		newExpense.value = [nf numberFromString:self.valueField.text];
		newExpense.category = _categorySelected;
		expenseViewController.expense = newExpense;
		expenseViewController.isNew = @YES;
	}
}

#pragma mark - View Lifecycle

-(void) addLabelForCategory: (Category *)category {
	MHLabel *label = [[MHLabel alloc] initWithFrame:CGRectZero];
	
	label.text = category.name;
	
	[label sizeToFit];
	[label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width + 10.0, label.frame.size.height)];
	[label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(categoryLabelTapped:)]];
	
	[_labels addObject:label];
	[self.scrollView addSubview:label];
}

-(void)refreshCategoryLabels {
	for (int i = _labels.count -1; i >= 0; --i){
		UILabel *label = [_labels objectAtIndex:i];
		[label removeFromSuperview];
		[_labels removeObjectAtIndex:i];
	}
	
	NSArray *categories = [[ExpenseStore sharedStore] allCategories];
	for (int i = 0; i < categories.count; i++){
		Category *category = [categories objectAtIndex:i];
		[self addLabelForCategory:category];
	}
	
}

-(void) refreshCategoryLayout {

	[MHLabel adjustLabelFrames:_labels forScrollView:self.scrollView];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_categorySelected = nil;
	self.valueField.text = nil;
	[self.valueField becomeFirstResponder];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	_isMenuVisible = @NO;
	[self refreshCategoryLabels];
	[self refreshCategoryLayout];
	
}


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[UIView animateWithDuration:0.25 animations:^{
		[self refreshCategoryLayout];
	}];
}

-(void) categoryLabelTapped: (UITapGestureRecognizer *)recognizer {
	UILabel *label = (UILabel *) recognizer.view;
	_categorySelected = [[[ExpenseStore sharedStore] allCategories] objectAtIndex:[_labels indexOfObject:label]];
	[self performSegueWithIdentifier:@"MainViewToNewExpenseView" sender:self];
	
}
- (IBAction)menuButtonPressed:(id)sender {
	if (!_isMenuVisible.boolValue){
		
		self.menuView.frame = CGRectMake(0, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
		_isMenuVisible = @YES;
		
	} else {
		self.menuView.frame = CGRectMake(-160, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
		_isMenuVisible = @NO;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_labels = [NSMutableArray array];
	
}

-(IBAction)unwindSegueToMainView:(UIStoryboardSegue *)segue {

}

-(IBAction)unwindSegueFromCategoryEditViewToMainView:(UIStoryboardSegue *) segue {
	
}

@end
