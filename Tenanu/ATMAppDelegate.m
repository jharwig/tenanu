//
//  ATMAppDelegate.m
//  Tenanu
//
//  Created by Jason Harwig on 5/8/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import "ATMAppDelegate.h"

@implementation ATMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UITableView appearance] setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.000]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.600 alpha:1.000]];
    [[UIProgressView appearance] setProgressTintColor:[UIColor colorWithWhite:0.450 alpha:1.000]];
    [[UIProgressView appearance] setTrackTintColor:[UIColor colorWithWhite:0.950 alpha:1.000]];
    
    return YES;
}
							
- (void)applicationWillEnterForeground:(UIApplication *)application {

    NSDate *lastLoginDate = [[NSUserDefaults standardUserDefaults] objectForKey:kTenanuLastLoginDate];
    NSTimeInterval timeout = 5 /*mins*/ * 60 /*seconds*/;
    if (!lastLoginDate || [[NSDate date] timeIntervalSinceDate:lastLoginDate] > timeout) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTenanuNotificationRefreshNeeded object:nil];
    }
}

@end
