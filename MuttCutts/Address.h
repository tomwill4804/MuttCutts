//
//  Address.h
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (strong, nonatomic) NSString* street;
@property (strong, nonatomic) NSString* city;
@property (strong, nonatomic) NSString* state;
@property                     BOOL      updated;

@end
