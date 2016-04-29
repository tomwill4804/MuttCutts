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
    
    CLLocation *fromLocation;
    CLLocation *toLocation;
    
    UIButton* buttonAddress;
    __strong id* locationAddress;
    
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
        buttonAddress = self.fromAddressButton;
        locationAddress = &fromLocation;
        
    }
    if ([[segue identifier] isEqualToString:@"toAddress"]){
        vc.address = toAddress;
        buttonAddress = self.toAddressButton;
        locationAddress = &toLocation;
    }
    
}


//
//  set the right address field
//
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    AddressViewController *vc = (AddressViewController *)segue.sourceViewController;
    
    UIButton* button = buttonAddress;
    NSString* newAddr = [NSString stringWithFormat:@"%@, %@", vc.address.city, vc.address.state];

    [button setTitle:newAddr forState:UIControlStateNormal];
    
    //
    //  allocate a geocoder
    //
    if(self.geocoder == nil)
    {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    //
    //  find location and annotate it
    //
    [self.geocoder geocodeAddressString:newAddr completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(placemarks.count > 0) {
        
            CLPlacemark *bestResult = [placemarks objectAtIndex:0];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:bestResult];
            [self.mapView addAnnotation:placemark];
            *locationAddress = bestResult.location;
            
            //
            //  see if we can calc distnce and zoom
            //
            if (fromLocation && toLocation){
                float distance = [fromLocation distanceFromLocation:toLocation] * 0.000621371192;
                [self zoomMapToRegionEncapsulatingLocation:fromLocation andLocation:toLocation];
                self.messageLabel.text = [NSString stringWithFormat:@"Distance is %g miles", distance];
            }

        }
    }];
    
    
}

//
//  zoom to two locations on a map
//
-(void)zoomMapToRegionEncapsulatingLocation:(CLLocation*)firstLoc andLocation:(CLLocation*)secondLoc{
    
    float lat =(firstLoc.coordinate.latitude + secondLoc.coordinate.latitude) /2;
    
    float longitude = (firstLoc.coordinate.longitude + secondLoc.coordinate.longitude) /2;
    
    
    CLLocationDistance distance = [firstLoc distanceFromLocation:secondLoc];
    CLLocation *centerLocation = [[CLLocation alloc]initWithLatitude:lat longitude:longitude];
    
    if (CLLocationCoordinate2DIsValid(centerLocation.coordinate)){
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerLocation.coordinate, distance,distance);
        [self.mapView setRegion:region animated:YES];
    }
}


@end
