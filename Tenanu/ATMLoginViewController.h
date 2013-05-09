//
//  ATMLoginViewController.h
//  Tenanu
//
//  Created by Jason Harwig on 5/8/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMLoginViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@property (strong, nonatomic) NSString *errorMessage;

- (IBAction)updated:(id)sender;


@end
