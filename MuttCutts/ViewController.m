//
//  ViewController.m
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import "ViewController.h"
#import "AddressViewController.h"

@interface ViewController () {
    
    NSString *fromAddress;
    NSString *toAddress;
    
    __strong id* address;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    fromAddress = @"from";
    toAddress = @"to";
    
}


//
//  set values array for selector
//
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"fromAddress"])
        address = &fromAddress;
    if ([[segue identifier] isEqualToString:@"toAddress"])
        address = &toAddress;
    
}


//
//  back from segue build a new entry in the array
//
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    AddressViewController *vc = (AddressViewController *)segue.sourceViewController;
    
    *address = [vc.address copy];
    NSLog(@"%@", fromAddress);
    NSLog(@"%@", toAddress);
    
    
}

@end
