//
//  NSString+JSON.m
//  Ketled
//
//  Created by Jason Harwig on 1/8/13.
//
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (id)jsonObject {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (!result)
        NSLog(@"%@", error);

    return result;
}

@end
