//
//  RemoteService.m
//  Ketled
//
//  Created by Jason Harwig on 1/8/13.
//
//

#import "RemoteService.h"
#import "SynchronousWebView.h"
#import "AccountRequest.h"

@implementation RemoteService

+ (id)sharedInstance {return nil;}

- (id) init
{
	self = [super init];
	if (self != nil) {
        workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        [workerThread start];
	}
	return self;
}


- (void)run {
    @autoreleasepool {
        syncronousWebView = [[SynchronousWebView alloc] init];
        while (YES) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        }
    }
}

- (void)chargesWithCompletion:(void(^)(AccountRequest *request, NSString *errorMessage)) block {}
- (void)leaveBalanceWithCompletion:(void(^)(NSString *balance, NSString *errorMessage)) block {}
- (void)saveHours:(NSString *)hours accountIndex:(NSUInteger)accountIndex dayIndex:(NSUInteger)dayIndex completion:(void(^)(BOOL success, NSString *errorMessage))completion {}

@end
