//
//  ViewController.m
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import "ViewController.h"
#import "AddressViewController.h"
#import "Address.h"

@interface ViewController () {
    
    Address *fromAddress;
    Address *toAddress;
    
    __weak id* buttonAddress;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    fromAddress = [[Address alloc] init];
    toAddress = [[Address alloc] init];
    
}


//
//  set pointer to address field we want to set when we come back
//
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    AddressViewController *vc = (AddressViewController *)segue.destinationViewController;
    
    if ([[segue identifier] isEqualToString:@"fromAddress"]) {
        vc.address = fromAddress;
        buttonAddress = &_fromAddressButton;
    }
    if ([[segue identifier] isEqualToString:@"toAddress"]){
        vc.address = toAddress;
        buttonAddress = &_toAddressButton;
    }
    
}


//
//  set the right address field
//
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    AddressViewController *vc = (AddressViewController *)segue.sourceViewController;
    
    UIButton* button = *buttonAddress;
    NSString* newAddr = [NSString stringWithFormat:@"%@, %@", vc.address.city, vc.address.state];

    [button setTitle:newAddr forState:UIControlStateNormal];
    
}

@end
