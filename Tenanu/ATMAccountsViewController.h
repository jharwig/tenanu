//
//  ATMMasterViewController.h
//  Tenanu
//
//  Created by Jason Harwig on 5/8/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMAccountsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIProgressView *daysProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *hoursProgress;
@property (weak, nonatomic) IBOutlet UILabel *hoursText;
@property (weak, nonatomic) IBOutlet UILabel *daysText;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *leaveBalanceText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)toggleWebview:(id)sender;

- (IBAction)refresh:(id)sender;
@end
