//
//  SynchronousWebView.h
//  Deltek
//
//  Every call blocks until completion. Call on background thread!
//  All UIWebView calls happen on the main thread
//
//  Created by Jason Harwig on 3/15/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SynchronousWebView : NSObject<UIWebViewDelegate> 

@property (nonatomic, retain) UIWebView *webview;

- (void)load:(NSString *)url;
- (BOOL)waitForElement:(NSString *)cssSelector;
- (BOOL)waitForElement:(NSString *)cssSelector errorElement:(NSString *)errorCssSelector;

- (id)resultFromScript:(NSString *)scriptName;
- (id)resultFromScript:(NSString *)scriptName input:(NSDictionary *)input;
@end
