//
//  RemoteService.h
//  Ketled
//
//  Created by Jason Harwig on 1/8/13.
//
//

#import <Foundation/Foundation.h>

@class SynchronousWebView, AccountRequest, Account;

#define RETRY_COUNT 4

@interface RemoteService : NSObject<UIWebViewDelegate>  {
    NSThread *workerThread;
    SynchronousWebView *syncronousWebView;
}

+ (id)sharedInstance;

- (void)leaveBalanceWithCompletion:(void(^)(NSString *balance, NSString *errorMessage)) block;
- (void)chargesWithCompletion:(void(^)(AccountRequest *request, NSString *errorMessage)) block;
- (void)saveHours:(NSString *)hours account:(Account *)account dayIndex:(NSUInteger)dayIndex completion:(void(^)(BOOL success, NSString *errorMessage))completion;

@end
