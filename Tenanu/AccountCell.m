//
//  AccountCell.m
//  Ketled
//
//  Created by Jason Harwig on 1/8/13.
//
//

#import "AccountCell.h"
#import "Account.h"

@implementation AccountCell

- (void)setAccount:(Account *)anAccount {
    _account = anAccount;
    
    self.accountLabel.text = _account.name;
    self.hoursLabel.text = [[NSNumber numberWithFloat:_account.totalHours] formattedNumber];
}

@end
