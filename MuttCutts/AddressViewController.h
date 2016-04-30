//
//  AddressViewController.h
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Address.h"

@interface AddressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField* street;
@property (weak, nonatomic) IBOutlet UITextField* city;
@property (weak, nonatomic) IBOutlet UITextField* state;

@property (strong, nonatomic) Address* address;

@property (weak, nonatomic) IBOutlet UIButton *okButton;


@end
