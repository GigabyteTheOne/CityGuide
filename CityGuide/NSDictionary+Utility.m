//
//  NSDictionary+Utility.m
//  PPDashboards
//
//  Created by Konstantin Simakov on 19.04.13.
//  Copyright (c) 2013 JSC Prognoz. All rights reserved.
//

#import "NSDictionary+Utility.h"

@implementation NSDictionary (Utility)

- (id)valueForKeyNotNull:(id)key {
    id object = [self valueForKey:key];
    if (object == [NSNull null])
        return nil;
    
    return object;
}

@end
