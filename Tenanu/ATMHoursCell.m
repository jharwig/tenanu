//
//  ATMHoursCell.m
//  Tenanu
//
//  Created by Jason Harwig on 5/9/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import "ATMHoursCell.h"

static NSDateFormatter *dateFormatter;

@implementation ATMHoursCell

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
}

- (void)setDate:(NSDate *)date {
    _date = date;
    

    [dateFormatter setDateFormat:@"EEE"];
    self.dayOfWeekLabel.text = [[dateFormatter stringFromDate:date] uppercaseString];
    
    [dateFormatter setDateFormat:@"dd"];
    self.dayOfMonthLabel.text = [dateFormatter stringFromDate:date];
    
    self.dayOfMonthLabel.textColor = self.dayOfWeekLabel.textColor =
        [date isToday] ?
        [[UINavigationBar appearance] backgroundColor]
        :
        self.monthOfYear.textColor;
    
    self.todayMarker.hidden = ![date isToday];
    
    [dateFormatter setDateFormat:@"MMM"];
    self.monthOfYear.text = [[dateFormatter stringFromDate:date] uppercaseString];
}

- (void)setHours:(NSString *)hours {
    _hours = hours;

    self.hoursSuffixLabel.hidden = hours == nil;
    self.hoursLabel.text = hours;
}

@end
