//
//  SubmitRequest.m
//  Tenanu
//
//  Created by Jason Harwig on 5/16/13.
//  Copyright (c) 2013 Altamira. All rights reserved.
//

#import "SubmitRequest.h"

@implementation SubmitRequest

- (void)submitWithAuditComment:(NSString *)comment {
    self.submitCommentBlock(comment);
}

@end
