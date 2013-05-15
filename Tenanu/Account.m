//
//  Account.m
//  Ketled
//
//  Created by Jason Harwig on 3/23/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "Account.h"


@implementation Account


+ (id)accountWithJsonDictionary:(NSDictionary *)d {
    Account *inst = [[Account alloc] init];
    
    inst.name = [d objectForKey:@"name"];
    inst.code = [d objectForKey:@"code"];
    inst.hours = [d objectForKey:@"hours"];
    inst.unused = [[d objectForKey:@"unused"] boolValue];
    inst.optionValue = [d objectForKey:@"optionVal"];
    
    return inst;
}


- (float)totalHours {
    float total = 0;
    for (NSNumber *hoursInDay in self.hours) {
        if (![hoursInDay isEqual:[NSNull null]]) {
            total += [hoursInDay floatValue];
        }
    }
    return total;
}

@end
