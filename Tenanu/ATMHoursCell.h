//
//  ATMHoursCell.h
//  Tenanu
//
//  Created by Jason Harwig on 5/9/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATMHoursCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dayOfWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayOfMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthOfYear;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursSuffixLabel;
@property (weak, nonatomic) IBOutlet UIView *todayMarker;

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *hours;

@end
