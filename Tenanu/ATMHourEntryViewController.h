//
//  ATMHourEntryViewController.h
//  Tenanu
//
//  Created by Jason Harwig on 5/9/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMHourEntryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *hourField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) NSString *accountName;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *hours;

- (IBAction)done:(id)sender;

@end
