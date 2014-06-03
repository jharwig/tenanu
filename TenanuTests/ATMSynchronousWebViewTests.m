//
//  ATMSynchronousWebViewTests.m
//  Tenanu
//
//  Created by Jason Harwig on 5/8/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//



#import "ATMSynchronousWebViewTests.h"
#import "SynchronousWebView.h"


#define UNANET_LOGIN @"https://timecards.altamiracorp.com/action/login"
#define ASYNC(Block) \
    do {  \
        __block BOOL finished = NO; \
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  \
            SynchronousWebView *wv = [[SynchronousWebView alloc] init]; \
            { \
                Block \
            }; \
            finished = YES; \
        }); \
        while (!finished) { \
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]; \
        } \
    } while(0);


@implementation ATMSynchronousWebViewTests

- (void)testLoad
{
    ASYNC(
          [wv load:UNANET_LOGIN];
          XCTAssertTrue([wv waitForElement:@"#username"], @"Page contains username field");
          XCTAssertTrue([wv waitForElement:@"#password"], @"Page contains password field");
    );
}

- (void)testLogin
{
    NSDictionary *cred = @{@"login": @"", @"password": @""};
    ASYNC(
          [wv load:UNANET_LOGIN];
          [wv resultFromScript:@"login.js" input:cred];
          BOOL result = [wv waitForElement:@"#active-timesheet-list"];
          
          XCTAssertTrue(result, @"Could not find active timesheets");
    );
}

@end
