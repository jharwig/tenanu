//
//  AccountRequest.h
//  Ketled
//
//  Created by Jason Harwig on 3/23/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AccountRequest : NSObject {    
    NSArray *startDate;
    NSArray *accounts;
    float required;
    
@private
    
    NSUInteger totalWorkdays;
    NSUInteger finishedWorkdays;
}

@property (nonatomic, copy) NSArray *dateRange;
@property (nonatomic, copy) NSArray *accounts;
@property (nonatomic, assign) float required;
@property (nonatomic, readonly) float totalHours;


+ (id)accountRequestWithJsonDictionary:(NSDictionary *)json;

- (BOOL)isValid;
- (NSString *)totalHoursDescription;
- (float)hoursPercentage;
- (NSString *)totalDaysDescription;
- (float)daysPercentage;
@end
