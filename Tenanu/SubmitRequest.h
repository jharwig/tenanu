//
//  SubmitRequest.h
//  Tenanu
//
//  Created by Jason Harwig on 5/16/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AuditCommentBlock)(NSString *comment);

@interface SubmitRequest : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) BOOL needsAudit;

@property (nonatomic, strong) NSArray *changes;
@property (nonatomic, copy) AuditCommentBlock submitCommentBlock;


- (void)submitWithAuditComment:(NSString *)comment;

@end
