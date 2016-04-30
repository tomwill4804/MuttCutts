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
    if (vc.address.updated && vc.address.city.length > 0) {
        NSString* newAddr = [NSString stringWithFormat:@"%@ %@, %@",
                             vc.address.street, vc.address.city, vc.address.state];
        
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
                //  see if we can calc distnce, zoom, and route
                //
                if (fromLocation && toLocation){
                    
                    float distance = [fromLocation distanceFromLocation:toLocation] * 0.000621371192;
                    self.messageLabel.text = [NSString stringWithFormat:@"Distance is %g miles", distance];
                    
                    [self zoomMapToRegionEncapsulatingLocation:fromLocation andLocation:toLocation];
                    [self directions:fromLocation andLocation:toLocation];
                    
                }
                
            }
        }];
        
    }
    
    
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


//
//  calc directions from two points
//
-(void)directions:(CLLocation*)firstLoc andLocation:(CLLocation*)secondLoc{

    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark* placemark1 = [[MKPlacemark alloc] initWithCoordinate:firstLoc.coordinate addressDictionary:nil];
    request.source = [[MKMapItem alloc] initWithPlacemark:placemark1];

    MKPlacemark* placemark2 = [[MKPlacemark alloc] initWithCoordinate:secondLoc.coordinate addressDictionary:nil];
    request.destination = [[MKMapItem alloc] initWithPlacemark:placemark2];

    request.requestsAlternateRoutes = NO;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateDirectionsWithCompletionHandler:
        ^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            } else {
                [self showRoute:response];
            }
        }];

}



//
//  update the map for the directions
//
-(void)showRoute:(MKDirectionsResponse *)response{

    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}


//
//  draw the line for the map route
//
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

@end
