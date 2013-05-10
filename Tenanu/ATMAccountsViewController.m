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
}
@property (nonatomic, strong) AccountRequest *accountRequest;
@end

@implementation ATMAccountsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeoutNotification:) name:kTenanuNotificationRefreshNeeded object:nil];
    
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

- (IBAction)refresh:(id)sender {
    
    if (!self.accountRequest)
        self.footerView.hidden = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Loading";
	[[UnanetService sharedInstance] chargesWithCompletion:^(AccountRequest *anAccountRequest, NSString *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!anAccountRequest) {
            errorMessage = error;
            [self performSegueWithIdentifier:@"login" sender:nil];
            return;
        }
        
        self.accountRequest = anAccountRequest;
        
        if ([self.accountRequest isValid]) {
            [self updateProgress];
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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accountRequest.accounts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChargeCell";
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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


@end
