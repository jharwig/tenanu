//
//  AccountRequest.m
//  Ketled
//
//  Created by Jason Harwig on 3/23/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "AccountRequest.h"
#import "NSNumberExtensions.h"
#import "Account.h"

@implementation AccountRequest

@synthesize dateRange, accounts, required;

+ (id)accountRequestWithJsonDictionary:(NSDictionary *)json {
    AccountRequest *inst = [[AccountRequest alloc] init];

    NSMutableArray *mAccounts = [NSMutableArray array];
    NSArray *accountDictionaries = [json objectForKey:@"accounts"];
    for (NSDictionary *accountDictionary in accountDictionaries) {
        [mAccounts addObject:[Account accountWithJsonDictionary:accountDictionary]];
    }
    inst.accounts = mAccounts;    
    inst.required = [[json objectForKey:@"required"] floatValue];
            
    NSArray *startDateComponents = [json objectForKey:@"startDate"];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:[[startDateComponents objectAtIndex:0] intValue]];
    [comps setMonth:[[startDateComponents objectAtIndex:1] intValue]];
    [comps setDay:[[startDateComponents objectAtIndex:2] intValue]];    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *startDate = [cal dateFromComponents:comps];
    NSDateComponents *endComps = [[NSDateComponents alloc] init];
    [endComps setDay:[[json objectForKey:@"daysInPeriod"] intValue] - 1];
    NSDate *endDate = [cal dateByAddingComponents:endComps toDate:startDate options:0];

    inst.dateRange = [NSArray arrayWithObjects:startDate, endDate, nil];
    
    return inst;
}


- (NSString *)totalHoursDescription {
    return [NSString stringWithFormat:@"%@ of %@ hours", 
        [[NSNumber numberWithFloat:self.totalHours] formattedNumber], 
        [[NSNumber numberWithFloat:required] formattedNumber]];
}

- (float)hoursPercentage {
    return (float)self.totalHours / required;
}


- (void)setDateRange:(NSArray *)aDateRange {
    dateRange = aDateRange;
    
    if ([self isValid]) {        
        NSDate *start = [dateRange objectAtIndex:0];
        NSDate *end = [dateRange objectAtIndex:1];
        
        // Total Number of Days in Range
        NSCalendar *cal = [NSCalendar currentCalendar];    
        NSInteger totalDays = [[cal components:NSDayCalendarUnit fromDate:start toDate:end options:0] day] + 1;
        NSInteger finishedDays = [[cal components:NSDayCalendarUnit fromDate:start toDate:[NSDate date] options:0] day] + 1;
        
        int totalWeekendDaysFound = 0, weekendDaysFound = 0;
        
        NSDateComponents *daysComponent = [[NSDateComponents alloc] init];
        for (int i = 0; i < totalDays; i++) {
            [daysComponent setDay:i];        
            NSDate *d = [cal dateByAddingComponents:daysComponent toDate:start options:0];
            NSDateComponents *dayOfWeek = [cal components:NSWeekdayCalendarUnit fromDate:d];                
            if ([dayOfWeek weekday] == 1 || [dayOfWeek weekday] == 7) {
                totalWeekendDaysFound++;
                if ([d compare:[NSDate date]] != NSOrderedDescending) {
                    weekendDaysFound++;
                }
            }                
        }    
        
        finishedWorkdays = finishedDays - weekendDaysFound;
        totalWorkdays = totalDays - totalWeekendDaysFound;
    }
}

- (NSString *)totalDaysDescription {
    return [NSString stringWithFormat:@"%lu of %lu workdays", finishedWorkdays, totalWorkdays];
}

- (float)daysPercentage {
    return (float)finishedWorkdays / totalWorkdays;
}

- (float)totalHours {
    float total = 0;
    for (Account *account in accounts) {
        total += account.totalHours;
    }
    return total;
}

- (BOOL)isValid {
    return [self.accounts count] > 0 && [dateRange count] == 2;
}

@end
