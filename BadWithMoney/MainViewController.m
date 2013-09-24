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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *menuVisibleConstraint;
@property (strong, nonatomic) NSLayoutConstraint *menuHiddenConstraint;

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
        
		[self.navigationController setNavigationBarHidden:YES];
		
		if ([[[ExpenseStore sharedStore] allExpenses] count] == 0){
			[FakeExpense generateRandomExpenses:10];
		}		
    }
    return self;
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
	
	UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
	leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[leftSwipeRecognizer setNumberOfTouchesRequired:1];
	[self.view addGestureRecognizer:leftSwipeRecognizer];
	
	self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view removeConstraint:self.menuVisibleConstraint];
	self.menuHiddenConstraint = [NSLayoutConstraint
								 constraintWithItem:self.menuView
								 attribute:NSLayoutAttributeTrailing
								 relatedBy:NSLayoutRelationEqual
								 toItem:self.view
								 attribute:NSLayoutAttributeLeading
								 multiplier:1.0f
								 constant:0.0f];
	[self.view addConstraint:self.menuHiddenConstraint];
	
	
	
	if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
	
	[self hideMenu];
	
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self hideMenu];
	_categorySelected = nil;
	self.valueField.text = nil;
	[self.valueField becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self hideMenu];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	_isMenuVisible = @NO;
	self.menuView.layer.borderColor = [UIColor blackColor].CGColor;
	self.menuView.layer.borderWidth = 2.0;
	[self refreshCategoryLabels];
	[self refreshCategoryLayout];
	
}

#pragma mark - Storyboard Segue Methods

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

#pragma mark - Fun With Labels

-(void) addLabelForString: (NSString *)string {
	MHLabel *label = [[MHLabel alloc] initWithFrame:CGRectZero];
	label.text = string;
	
	[label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)]];
	[_labels addObject:label];
	[self.scrollView addSubview:label];
}

-(void)refreshCategoryLabels {
	for (int i = _labels.count -1; i >= 0; --i){
		MHLabel *label = [_labels objectAtIndex:i];
		[label removeFromSuperview];
		[_labels removeObjectAtIndex:i];
	}
	
	NSArray *categories = [[ExpenseStore sharedStore] allCategories];
	for (int i = 0; i < categories.count; i++){
		Category *category = [categories objectAtIndex:i];
		[self addLabelForString:category.name];
	}
}

-(void) refreshCategoryLayout {
	[MHLabel adjustLabelFrames:_labels forScrollView:self.scrollView];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[UIView animateWithDuration:0.25 animations:^{
		[self refreshCategoryLayout];
	}];
}

-(void) labelTapped: (UITapGestureRecognizer *)recognizer {
	MHLabel *label = (MHLabel *) recognizer.view;
	_categorySelected = [[[ExpenseStore sharedStore] allCategories] objectAtIndex:[_labels indexOfObject:label]];
	[self performSegueWithIdentifier:@"MainViewToNewExpenseView" sender:self];
}

#pragma mark - MenuView Operations

-(IBAction)didSwipeLeft:(id)sender {
	[self hideMenu];
}

-(IBAction)didSwipeRight:(id)sender {
	[self showMenu];
}

- (IBAction)menuButtonPressed:(id)sender {
	if (_isMenuVisible.boolValue){
		[self hideMenu];
	} else {
		[self showMenu];
	}
}
-(void) showMenu {
	if (!_isMenuVisible.boolValue){
		_isMenuVisible = @YES;
		
		self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view removeConstraint:self.menuHiddenConstraint];
		[self.view addConstraint:self.menuVisibleConstraint];
		[self.view setNeedsUpdateConstraints];
		
		[UIView animateWithDuration:0.25 animations:^{
//			self.menuView.frame = CGRectMake(-2, -2, self.menuView.frame.size.width, self.menuView.frame.size.height);
			[self.view layoutIfNeeded];
		}];
	}
}

-(void) hideMenu {
	if (_isMenuVisible.boolValue){
		_isMenuVisible = @NO;
		
		self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view removeConstraint:self.menuVisibleConstraint];
		[self.view addConstraint:self.menuHiddenConstraint];
		[self.view setNeedsUpdateConstraints];
		
		[UIView animateWithDuration:0.25 animations:^{
			[self.view layoutIfNeeded];
//			self.menuView.frame = CGRectMake(-142, -2, self.menuView.frame.size.width, self.menuView.frame.size.height);
		}];
	}
}

#pragma mark - Storyboard Unwind Segues

-(IBAction)unwindSegueToMainView:(UIStoryboardSegue *)segue {

}

-(IBAction)unwindSegueFromCategoryEditViewToMainView:(UIStoryboardSegue *) segue {

}

@end
