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
    
    self.city.text = self.address.city;
    self.state.text = self.address.state;
    
}

-(IBAction)okButtonClicked:(id)sender{
    
    self.address.city = self.city.text;
    self.address.state = self.state.text;
    
}

-(IBAction)cancelButtonClicked:(id)sender{
    
    
    
}

@end
