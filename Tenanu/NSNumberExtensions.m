//
//  NSNumberExtensions.m
//  Deltek
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "NSNumberExtensions.h"


@implementation NSNumber (NSNumberExtensions)

- (NSString *)formattedNumber {
        
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setMaximumFractionDigits:2];
    [f setMinimumFractionDigits:0];
    [f setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    
    return [f stringFromNumber:self];
}

@end
