//
//  Address.m
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import "Address.h"

@implementation Address

- (instancetype)init
{
    self = [super init];
    if (self) {
        _street = @"";
        _city = @"";
        _state = @"";
    }
    return self;
}

@end
