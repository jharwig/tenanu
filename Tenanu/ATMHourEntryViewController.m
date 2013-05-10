//
//  ATMHourEntryViewController.m
//  Tenanu
//
//  Created by Jason Harwig on 5/9/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import "ATMHourEntryViewController.h"
#import "UnanetService.h"

@interface ATMHourEntryViewController () 
@property (nonatomic, strong) NSArray *pickerMinutes;
@property (nonatomic, strong) NSArray *pickerHours;
@end


static NSDateFormatter *formatter;

@implementation ATMHourEntryViewController

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.accountLabel.text = self.accountName;
    self.hourField.text = self.hours;
    self.dateLabel.text = [formatter stringFromDate:self.date];
    
    [self setupPicker];
}

- (void)setHours:(NSString *)hours {
    _hours = hours;
    self.hourField.text = hours;
}

- (IBAction)done:(id)sender {
    UIViewController *controller = self.presentingViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = [(id)controller topViewController];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Saving";
        
    [[UnanetService sharedInstance] saveHours:self.hours
                                 accountIndex:[[controller valueForKeyPath:@"accountIndex"] integerValue]
                                     dayIndex:[[controller valueForKeyPath:@"savedHoursIndexPath"] row]
                                   completion:^(BOOL success, NSString *errorMessage) {
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       
                                       if (errorMessage) {
                                           [[[UIAlertView alloc] initWithTitle:(success ? @"Warning" : @"Error")
                                                                       message:errorMessage
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil] show];
                                       }
                                       
                                       if (success) {
                                           
                                           
                                           if ([controller respondsToSelector:@selector(updateHoursFromEntryForm:)]) {
                                               [controller performSelector:@selector(updateHoursFromEntryForm:) withObject:self.hours];
                                           }

                                           
                                           [self dismissViewControllerAnimated:YES completion:NULL];
                                       }
                                   }];    
}

#pragma mark UIPicker Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return component == 0 ? [self.pickerHours count] : component == 1 ? 1 : [self.pickerMinutes count];
}


#pragma mark UIPicker Delegate


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return component == 0 ? 100 : component == 1 ? 31 : 100;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UILabel *)label {
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, component == 1 ? 13 : 70, 44)];
        label.textColor = component == 0 ? [UIColor blackColor] : [UIColor colorWithWhite:0.2 alpha:1.0];
        label.textAlignment = component == 2 ? NSTextAlignmentLeft : NSTextAlignmentRight;
        label.font = [UIFont boldSystemFontOfSize:30];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = YES;
    }
    
    label.text = component == 0 ? [self.pickerHours objectAtIndex:row] : component == 1 ? @"." : [self.pickerMinutes objectAtIndex:row];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSString *hour = [self.pickerHours objectAtIndex:[pickerView selectedRowInComponent:0]];
    NSString *minute = [self.pickerMinutes objectAtIndex:[pickerView selectedRowInComponent:2]];
    
    if ([minute isEqualToString:@"0"])
        self.hours = hour;
    else
        self.hours = [NSString stringWithFormat:@"%@.%@", hour, minute];
}


#pragma mark - Private

- (void)setupPicker {
    NSMutableArray *h = [NSMutableArray array];
    NSMutableArray *m = [NSMutableArray array];
    int selectedHourRow = NSNotFound;
    int selectedMinuteRow = NSNotFound;
    
    NSRange r = [self.hours rangeOfString:@"."];
    NSString *hourComponent = nil;
    NSString *minuteComponent = nil;
    if (r.location == NSNotFound) {
        hourComponent = self.hours;
        minuteComponent = @"0";
    } else {
        hourComponent = [self.hours substringToIndex:r.location];
        minuteComponent = [self.hours substringFromIndex:r.location+1];
    }
    
    for (int i = 0; i <= 10; i++) {
        NSString *hour = [NSString stringWithFormat:@"%i", i];
        [h addObject:hour];
        
        if ([hourComponent isEqualToString:hour])
            selectedHourRow = i;
        
        if (i < 10) {
            NSString *minute = [NSString stringWithFormat:@"%i", i];
            [m addObject:minute];
            
            if ([minuteComponent isEqualToString:minute])
                selectedMinuteRow = i;
        }
    }
    
    self.pickerHours = [NSArray arrayWithArray:h];
    self.pickerMinutes = [NSArray arrayWithArray:m];
    
    [self.pickerView reloadAllComponents];
    
    if (selectedHourRow != NSNotFound)
        [self.pickerView selectRow:selectedHourRow inComponent:0 animated:NO];
    
    if (selectedMinuteRow != NSNotFound)
        [self.pickerView selectRow:selectedMinuteRow inComponent:2 animated:NO];
}


@end
