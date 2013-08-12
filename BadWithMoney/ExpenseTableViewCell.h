//
//  ExpenseTableViewCell.h
//  BadWithMoney
//
//  Created by Mark on 8/9/13.
//  Copyright (c) 2013 Mark Hambly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpenseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
