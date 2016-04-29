//
//  AddressViewController.m
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import "AddressViewController.h"

@interface AddressViewController ()


@end

@implementation AddressViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

-(IBAction)okButtonClicked:(id)sender{
    
    self.address = [NSString stringWithFormat:@"%@ %@", self.city.text, self.state.text];
    
}

-(IBAction)cancelButtonClicked:(id)sender{
    
    
    
}

@end
