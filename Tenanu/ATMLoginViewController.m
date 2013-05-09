//
//  ATMLoginViewController.m
//  Tenanu
//
//  Created by Jason Harwig on 5/8/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import "ATMLoginViewController.h"

@interface ATMLoginViewController () {
    UIColor *savedColor;
}

@end

@implementation ATMLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    self.errorMessageLabel.text = self.errorMessage;
    savedColor = self.button.backgroundColor;
    
    NSDictionary *credentials = [[NSUserDefaults standardUserDefaults] objectForKey:kTenanuCredentials];
    

    self.errorMessageLabel.hidden = credentials == nil;

    
    self.urlField.text = credentials[@"url"] ? credentials[@"url"] : @"https://timecards.altamiracorp.com";
    self.usernameField.text = credentials[@"username"];
    //self.passwordField.text = @"";    
    
    [self updated:nil];
}


- (IBAction)updated:(id)sender {
    self.button.enabled =
        [self fieldValid:_urlField] &&
        [self fieldValid:_usernameField] &&
        [self fieldValid:_passwordField];
    
    self.button.backgroundColor = self.button.enabled ?
    savedColor : [UIColor grayColor];
}

- (BOOL)fieldValid:(UITextField *)f {
    NSString *val = [f.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (f == _urlField) {
        NSURL *url = [NSURL URLWithString:val];
        return url.scheme && url.host;
    }
    
    return [val length] > 0;
}

@end
