//
//  ATMMasterViewController.m
//  Tenanu
//
//  Created by Jason Harwig on 5/8/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import "ATMAccountsViewController.h"
#import "ATMLoginViewController.h"
#import "ATMHoursViewController.h"
#import "AccountRequest.h"
#import "AccountCell.h"
#import "Account.h"
#import "UnanetService.h"

@interface ATMAccountsViewController () {
    NSString *errorMessage;
    BOOL showUnusedAccounts;
}
@property (nonatomic, strong) AccountRequest *accountRequest;
@end

@implementation ATMAccountsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    showUnusedAccounts = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeoutNotification:) name:kTenanuNotificationRefreshNeeded object:nil];
    
    self.footerView.hidden = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    if (!self.accountRequest)
        [self refresh:nil];
}

- (void)timeoutNotification:(NSNotification *)n {
    [self.navigationController popToViewController:self animated:YES];
    [self refresh:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTenanuNotificationRefreshNeeded object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
    
    if (self.accountRequest) {
        [self updateProgress];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"login"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setErrorMessage:)]) {
            [segue.destinationViewController performSelector:@selector(setErrorMessage:) withObject:errorMessage];
        }
    } else if ([segue.destinationViewController isKindOfClass:[ATMHoursViewController class]] &&
               [sender isKindOfClass:[AccountCell class]]) {
        ATMHoursViewController *vc = segue.destinationViewController;
        AccountCell *cell = sender;
        vc.range = self.accountRequest.dateRange;
        vc.account = cell.account;
        vc.accountIndex = [self.accountRequest.accounts indexOfObject:cell.account];
    }
    [super prepareForSegue:segue sender:sender];
}

- (IBAction)toggleWebview:(id)sender {
    
    UIWebView *webview = (UIWebView *)[self.view.window viewWithTag:9999];
    
    
    if (webview) {
        [webview removeFromSuperview];
    } else {
        webview = [[UnanetService sharedInstance] valueForKeyPath:@"syncronousWebView.webview"];
        
        webview.tag = 9999;
        webview.frame = CGRectOffset(CGRectInset(self.view.window.bounds, 0, 150), 0, 150);
        [self.view.window addSubview:webview];
    }

}

- (IBAction)refresh:(id)sender {    
    showUnusedAccounts = NO;
    [self.tableView reloadData];
    
    if (!self.accountRequest)
        self.footerView.hidden = YES;

    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Loading";
    
	[[UnanetService sharedInstance] chargesWithCompletion:^(AccountRequest *anAccountRequest, NSString *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (!anAccountRequest) {
            errorMessage = error;
            [self performSegueWithIdentifier:@"login" sender:nil];
            return;
        }
        
        self.accountRequest = anAccountRequest;
        
        if ([self.accountRequest isValid]) {
            [self updateProgress];
            
            [self.activityIndicator startAnimating];
            self.activityIndicator.hidden = NO;
            self.leaveBalanceText.text = nil;
            [[UnanetService sharedInstance] leaveBalanceWithCompletion:^(NSString *balance, NSString *errorMessage) {
                self.leaveBalanceText.text = [balance stringByAppendingString:@" hours"];
                self.leaveBalanceText.hidden = NO;
                [self.activityIndicator stopAnimating];
                self.activityIndicator.hidden = YES;
            }];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unknown error occurred" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
		[self.tableView reloadData];
	}];
}

- (void)updateProgress {
    [_daysProgress setProgress:[self.accountRequest daysPercentage] animated:YES];
    _daysText.text = [self.accountRequest totalDaysDescription];
    
    _hoursText.text = [self.accountRequest totalHoursDescription];
    [_hoursProgress setProgress:[self.accountRequest hoursPercentage] animated:YES];
    
    self.footerView.hidden = NO;
}


- (IBAction)signIn:(UIStoryboardSegue *)segue {
    
    ATMLoginViewController *vc = segue.sourceViewController;
    [[NSUserDefaults standardUserDefaults] setObject:@{
     @"url": vc.urlField.text,
     @"username": vc.usernameField.text,
     @"password": vc.passwordField.text
     }
                                              forKey:kTenanuCredentials];
    [self refresh:nil];

}

- (NSArray *)accountsToDisplay {
    if (showUnusedAccounts)
        return self.accountRequest.accounts;
    
    return [self.accountRequest.accounts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"unused = NO"]];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [[self accountsToDisplay] count];
    if (count == 0) return 0;
    return count + (showUnusedAccounts ? 0 : 1);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AccountCellIdentifier = @"ChargeCell";
    static NSString *AddNewIdentifier = @"AddNewCell";
    
    NSArray *accounts = [self accountsToDisplay];
    if (indexPath.row >= [accounts count]) {
        return [tableView dequeueReusableCellWithIdentifier:AddNewIdentifier];
    }
    
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:AccountCellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    
    Account *account = [self.accountRequest.accounts objectAtIndex:indexPath.row];
    cell.account = account;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *accounts = [self accountsToDisplay];
    if (indexPath.row >= [accounts count]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSMutableArray *paths = [NSMutableArray array];
        int i = indexPath.row;
        for (Account *account in self.accountRequest.accounts) {
            if (account.unused) {
                [paths addObject:[NSIndexPath indexPathForRow:i++ inSection:indexPath.section]];
            }

        }
        
        [tableView insertRowsAtIndexPaths:paths
                         withRowAnimation:UITableViewRowAnimationTop];

        showUnusedAccounts = YES;
        [tableView endUpdates];
    }
}

@end
