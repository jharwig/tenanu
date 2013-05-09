//
//  ATMHoursViewController.m
//  Tenanu
//
//  Created by Jason Harwig on 5/9/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import "ATMHoursViewController.h"
#import "ATMHourEntryViewController.h"
#import "ATMHoursCell.h"
#import "Account.h"

@interface ATMHoursViewController () {
    NSIndexPath *savedHoursIndexPath;
}

@end

@implementation ATMHoursViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDateComponents *timeBetween = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                    fromDate:[self.range objectAtIndex:0]
                                                                      toDate:[NSDate date] options:0];
    int days = [timeBetween day];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:days inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (IBAction)cancelHours:(UIStoryboardSegue *)sender {
    savedHoursIndexPath = nil;
    [self.tableView reloadData];
}

- (void)updateHoursFromEntryForm:(NSString *)hours {
    if (!savedHoursIndexPath) return;
    
    NSMutableArray *mHours = [NSMutableArray arrayWithArray:self.account.hours];
    [mHours replaceObjectAtIndex:savedHoursIndexPath.row
                      withObject:[NSNumber numberWithFloat:[hours floatValue]]];
    self.account.hours = mHours;

    savedHoursIndexPath = nil;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ATMHourEntryViewController class]]) {
        ATMHoursCell *cell = sender;
        ATMHourEntryViewController *hourEntryViewController = segue.destinationViewController;
        
        savedHoursIndexPath = [self.tableView indexPathForCell:cell];
        
        hourEntryViewController.accountName = self.account.name;
        hourEntryViewController.date = cell.date;
        hourEntryViewController.hours = cell.hours;
    }
    
    [super prepareForSegue:segue sender:sender];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.account.hours count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HoursCell";
    
    ATMHoursCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    

    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *startDate = [self.range objectAtIndex:0];
    NSDateComponents *daysComp = [[NSDateComponents alloc] init];
    [daysComp setDay:indexPath.row];

    cell.date = [cal dateByAddingComponents:daysComp toDate:startDate options:0];

    id hoursWorked = [self.account.hours objectAtIndex:indexPath.row];
    if ([hoursWorked isEqual:[NSNull null]]) {
        cell.hours = nil;
    } else cell.hours = [hoursWorked formattedNumber];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ATMHoursCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    // Darken weekend days
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dayOfWeek = [cal components:NSWeekdayCalendarUnit fromDate:cell.date];
    if ([dayOfWeek weekday] == 1 || [dayOfWeek weekday] == 7) {
        cell.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // TODO: implement hour change
    /*
     NSNumber *hours = [account.hours objectAtIndex:indexPath.row];
     HourEntryViewController *vc = [[HourEntryViewController alloc] initWithAccount:account
     hours:hours];
     vc.delegate = self;
     [self presentViewController:vc animated:YES completion:NULL];
     */
}

@end
