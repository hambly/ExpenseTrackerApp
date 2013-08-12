//
//  CategoryEditViewController.m
//  BadWithMoney
//
//  Created by Mark on 8/12/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CategoryEditViewController.h"
#import "Expense.h"
#import "ExpenseStore.h"
#import "Category.h"
#import "MHLabel.h"

@interface CategoryEditViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteCategoryButton;



@end

@implementation CategoryEditViewController{
	NSMutableArray *_labels;
	Category *_categorySelected;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_labels = [NSMutableArray array];
	[self.deleteCategoryButton setEnabled:NO];
	
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.nameField becomeFirstResponder];
	[self refreshLabels];
	[self refreshLayout];
	
}

#pragma mark - Fun With labels

-(void) addLabelForCategory: (Category *)category {
	MHLabel *label = [[MHLabel alloc] initWithFrame:CGRectZero];
	
	label.text = [NSString stringWithFormat:@"%@ (%i)",category.name, category.expenseSet.count];
	
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

	NSArray *categories = [[ExpenseStore sharedStore] allCategories];
	for (int i = 0; i < categories.count; i++){
		Category *category = [categories objectAtIndex:i];
		[self addLabelForCategory:category];
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

-(void) labelTapped: (UITapGestureRecognizer *) recognizer {
	MHLabel *label = (MHLabel *) recognizer.view;
	
	Category *category = [[[ExpenseStore sharedStore] allCategories] objectAtIndex:[_labels indexOfObject:label]];
	_categorySelected = category;
	self.nameField.text = _categorySelected.name;
	[self.deleteCategoryButton setEnabled:YES];
	
	[self refreshLabels];
	[self refreshLayout];
}

- (IBAction)deleteCategoryButtonPressed:(id)sender {
	if (_categorySelected.expenseSet.count == 0){
		[[ExpenseStore sharedStore] removeCategory:_categorySelected];
		_categorySelected = nil;
		self.nameField.text = nil;
		[self refreshLabels];
		[self refreshLayout];
	} else if ([_categorySelected.name isEqualToString:@"Uncategorized"]){
		NSString *alertString = [NSString stringWithFormat:@"There are %i uncategorized orphans. There is nowhere else for them to go!", _categorySelected.expenseSet.count];
		[[[UIAlertView alloc] initWithTitle:nil
									message:alertString
								   delegate:self
						  cancelButtonTitle:@"Save the orphans"
						  otherButtonTitles:nil] show];
	} else {
		NSString *alertString = [NSString stringWithFormat:@"Deleting this category will result in %i little expense orphans. Orphans will be marked as Uncatagorized! Poor little things.", _categorySelected.expenseSet.count];
		[[[UIAlertView alloc] initWithTitle:nil
									message:alertString
								   delegate:self
						  cancelButtonTitle:@"Save the orphans"
						  otherButtonTitles:@"Show no mercy", nil] show];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1){
		bool success = NO;
		Category *uncategorized;
		for (Category *cat in [[ExpenseStore sharedStore] allCategories]){
			if ([cat.name isEqualToString:@"Uncategorized"]){
				success = YES;
				uncategorized = cat;
			}
		}
		if (!success){
			uncategorized = [[ExpenseStore sharedStore] createCategory];
			uncategorized.name = @"Uncategorized";
		}
		NSArray *allExpensesFromCategory = _categorySelected.expenseSet.allObjects;
		for (Expense *exp in allExpensesFromCategory){
			exp.category = uncategorized;
		}
		
		[[ExpenseStore sharedStore] removeCategory:_categorySelected];
		[self refreshLabels];
		[self refreshLayout];
	}
}

- (IBAction)doneButtonPressed:(id)sender {
	
	if (![self.nameField.text isEqualToString: @""]){
		if (_categorySelected != nil){
			_categorySelected.name = self.nameField.text;
		} else {
			Category *newCategory = [[ExpenseStore sharedStore] createCategory];
			newCategory.name = self.nameField.text;
		}
		
		[[ExpenseStore sharedStore] saveChanges];
	}
	[self performSegueWithIdentifier:@"UnwindSegueFromCategoryEditViewToMainView" sender:self];
}


@end
