//
//  Account.h
//  Ketled
//
//  Created by Jason Harwig on 3/23/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Account : NSObject {
    NSString *name;
    NSString *code;
    NSArray *hours;
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, copy) NSArray *hours;
@property (nonatomic, readonly) float totalHours;

+ (id)accountWithJsonDictionary:(NSDictionary *)d;
@end
