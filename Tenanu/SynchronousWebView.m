//
//  SynchronousWebView.m
//  Deltek
//
//  Created by Jason Harwig on 3/15/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "SynchronousWebView.h"

#define LOG_BEGIN    NSLog(@"    BEGIN> %@", NSStringFromSelector(_cmd));
#define LOG_FINISHED NSLog(@" FINISHED> %@", NSStringFromSelector(_cmd));
#define NSAssertMainThread() NSAssert([NSThread isMainThread], @"Not on main thread")

@interface SynchronousWebView () {
    dispatch_semaphore_t wait_sem;
    uint webViewLoads;
}

@end

@implementation SynchronousWebView

@synthesize webview;

- (void)reset {
    if (webview) {
        webview.delegate = nil;
        [webview stopLoading];
        webview.delegate = self;
    }
    webViewLoads = 0;
    
    wait_sem = dispatch_semaphore_create(0);
}

- (void)setFinished {
    if (wait_sem != NULL) {
        dispatch_semaphore_signal(wait_sem);
        wait_sem = NULL;
    }
}

- (void)load:(NSString *)url {  
    LOG_BEGIN
    [self reset];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    });
    
    dispatch_semaphore_wait(wait_sem, DISPATCH_TIME_FOREVER);

    LOG_FINISHED
}

- (BOOL)elementExists:(NSString *)selector {
    NSAssertMainThread();

    NSString *js = [NSString stringWithFormat:@"!!document.querySelectorAll('%@').length", selector];
    id response = [webview stringByEvaluatingJavaScriptFromString:js];    
    //NSLog(@"Checking for %@... %@\n%@", selector, response, [webview stringByEvaluatingJavaScriptFromString:@"document.body"]);
    return response != nil && [response isEqualToString:@"true"];
}


- (BOOL)waitForElement:(NSString *)cssSelector {
    return [self waitForElement:cssSelector errorElement:nil];
}

- (BOOL)waitForElement:(NSString *)cssSelector errorElement:(NSString *)errorCssSelector {
    BOOL success = YES;
    __block BOOL error = NO;
    __block BOOL exists = NO;
    
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!exists) {


        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (errorCssSelector && [self elementExists:errorCssSelector]) {
                error = YES;
                
            } else exists = [self elementExists:cssSelector];

        });

        if ((!exists && [(NSDate *)[NSDate date] compare:timeout] == NSOrderedDescending) || error) {
            success = NO;
            break;
        } else [NSThread sleepForTimeInterval:0.05];
    }

    return success;
}


- (id)resultFromScript:(NSString *)scriptName {
    return [self resultFromScript:scriptName input:nil];
}

- (id)resultFromScript:(NSString *)scriptName input:(NSDictionary *)input {
    LOG_BEGIN

    __block NSString *result = nil;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:scriptName withExtension:@"js"];
        NSString *s = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
        // replace $ with getbyid
        s = [s stringByReplacingOccurrencesOfString:@"$" withString:@"document.getElementById"];				 

        // Wrap in try catch
        s = [NSString stringWithFormat:@"_ketledLastError = ''; try { %@ } catch (e) { _ketledLastError = e.message; _ketledLastErrorLine = e.lineno; }", s];
        
        if (input) {
            for (NSString *inputKey in [input allKeys]) {
                s = [s stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#{%@}", inputKey] withString:[input valueForKey:inputKey]];										   
            }
        }
        
        result = [webview stringByEvaluatingJavaScriptFromString:s];
        
        NSString *errorMessage = [webview stringByEvaluatingJavaScriptFromString:@"_ketledLastError"];
        if (![errorMessage isEqualToString:@""]) {
            NSLog(@"%@: %@", [webview stringByEvaluatingJavaScriptFromString:@"_ketledLastErrorLine"], errorMessage);
            result = @"";
        }
    });
    
    LOG_FINISHED
    
    return result;
}


- (UIWebView *)webview {
    if (!webview) {
        webview = [[UIWebView alloc] init];
		webview.delegate = self;
    }
    
    return webview;
}


#pragma mark Delegate Methods


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	webViewLoads++;
    
    [webView stringByEvaluatingJavaScriptFromString:@"window.alert=null;"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	webViewLoads--;
	if (webViewLoads > 0) {
		return;
	}

    [self setFinished];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self setFinished];
}

@end
