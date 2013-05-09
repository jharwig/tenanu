//
//  AccountCell.h
//  Ketled
//
//  Created by Jason Harwig on 1/8/13.
//
//

#import <UIKit/UIKit.h>

@class Account;
@interface AccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) Account *account;

@end
