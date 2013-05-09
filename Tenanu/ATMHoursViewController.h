//
//  ATMHoursViewController.h
//  Tenanu
//
//  Created by Jason Harwig on 5/9/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Account;
@interface ATMHoursViewController : UITableViewController

@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) NSArray *range;
@property (nonatomic, assign) NSInteger accountIndex;

- (void)updateHoursFromEntryForm:(NSString *)hours;
@end
