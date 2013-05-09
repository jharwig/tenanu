//
//  UnanetService.m
//  Ketled
//
//  Created by Jason Harwig on 1/8/13.
//
//

// Uncomment to just use test data
//#define USE_TEST_DATA

#import "UnanetService.h"
#import "SynchronousWebView.h"
#import "AccountRequest.h"

@implementation UnanetService

+ (id)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[UnanetService alloc] init];
    });
    return sharedInstance;
}

- (BOOL)loginWithError:(NSString **)errorMessage {
    
    NSDictionary *cred = [[NSUserDefaults standardUserDefaults] objectForKey:kTenanuCredentials];
    if (!cred) {
        *errorMessage = @"No Login Credentials";        
        return NO;
    }
    
    [syncronousWebView load:[cred objectForKey:@"url"]];
    
    if (![syncronousWebView waitForElement:@"#active-timesheet-list" errorElement:@"input#password"]) {
        
        if ([syncronousWebView waitForElement:@"#password"]) {

            // Login
            [syncronousWebView resultFromScript:@"login" input:cred];
            if (![syncronousWebView waitForElement:@"#active-timesheet-list" errorElement:@"p.error"]) {
                *errorMessage = [syncronousWebView resultFromScript:@"loginError"];
                return NO;
            }
            
        } else {
            return NO;
        }
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kTenanuLastLoginDate];
    return YES;
}


- (void)chargesWithCompletion:(void(^)(AccountRequest *request, NSString *errorMessage)) block {
    
	if ([NSThread currentThread] != workerThread) {
		block = [block copy];
        // reset webview
        syncronousWebView.webview = nil;
        [self performSelector:_cmd onThread:workerThread withObject:block waitUntilDone:NO];
        return;
    }
    
#ifdef USE_TEST_DATA
//  Temp data for testing
    if (block) {
        NSString *json = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test-data" ofType:@"json"] encoding:NSUTF8StringEncoding error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{    
            block([AccountRequest accountRequestWithJsonDictionary:[json jsonObject]], nil);
        });
    }
    return;
#endif
    
    NSString *error = nil;
    if (![self loginWithError:&error]) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{ block(nil, error); });
        }
        return;
    }
        
    [syncronousWebView resultFromScript:@"navigateTimesheet"];
    
    
    
    
    if ([syncronousWebView waitForElement:@"#buttons"]) {
        NSString *accountsJson;
        int try = 1;
        do {
            accountsJson = [syncronousWebView resultFromScript:@"queryPage"];
            [NSThread sleepForTimeInterval:1.0];
        } while ([accountsJson length] == 0 && ++try <= RETRY_COUNT);
        
        NSDictionary *accounts = [accountsJson jsonObject];
        
        AccountRequest *request = [AccountRequest accountRequestWithJsonDictionary:accounts];
        
        if (block)
            dispatch_async(dispatch_get_main_queue(), ^{ block(request, nil); });
    }
}


- (void)saveHours:(NSString *)hours accountIndex:(NSUInteger)accountIndex dayIndex:(NSUInteger)dayIndex completion:(void(^)(BOOL success, NSString *errorMessage))block {
    
    if ([NSThread currentThread] != workerThread) {
		block = [block copy];
        
        NSInvocation *i = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]];
        [i setSelector:_cmd];
        [i setTarget:self];
        [i setArgument:&hours atIndex:2];
        [i setArgument:&accountIndex atIndex:3];
        [i setArgument:&dayIndex atIndex:4];
        [i setArgument:&block atIndex:5];
        [i retainArguments];
        [i performSelector:@selector(invoke) onThread:workerThread withObject:nil waitUntilDone:NO];
        return;
    }
    
    
    NSString *error = nil;
    if (![self loginWithError:&error]) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{ block(NO, error); });
        }
        return;
    }
    
    BOOL success = NO;
    
    [syncronousWebView resultFromScript:@"navigateEditTimesheet"];
    if ([syncronousWebView waitForElement:@"#timeContent"]) {
        
        [syncronousWebView resultFromScript:@"saveHours" input:@{
         @"accountIndex": [NSString stringWithFormat:@"%i", accountIndex],
         @"dayIndex":[NSString stringWithFormat:@"%i", dayIndex],
         @"hours": hours
         }];
        
        if (![syncronousWebView waitForElement:@"#timeContent" errorElement:@"form[name=comments]"]) {
            
            id result = [syncronousWebView resultFromScript:@"saveErrors"];
            NSLog(@"%@", result);
            error = @"Some audit comments required";

        } else success = YES;
                
    }
    
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{ block(success, error); });
    }
}
@end
