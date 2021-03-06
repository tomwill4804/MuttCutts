//
//  ViewController.m
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import "ViewController.h"
#import "AddressViewController.h"
#import "DirectionsViewController.h"
#import "Address.h"

@interface ViewController ()<UIPopoverPresentationControllerDelegate> {
    
    Address *fromAddress;
    Address *toAddress;
    
    CLLocation *fromLocation;
    CLLocation *toLocation;
    
    UIButton* buttonAddress;
    __strong id* locationAddress;
    
    NSMutableArray* directionsList;
    
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
    
    
    if ([[segue identifier] isEqualToString:@"fromAddress"]) {
        AddressViewController *vc = (AddressViewController *)segue.destinationViewController;
        vc.address = fromAddress;
        buttonAddress = self.fromAddressButton;
        locationAddress = &fromLocation;
        
    }
    else if ([[segue identifier] isEqualToString:@"toAddress"]){
        AddressViewController *vc = (AddressViewController *)segue.destinationViewController;
        vc.address = toAddress;
        buttonAddress = self.toAddressButton;
        locationAddress = &toLocation;
        vc.popoverPresentationController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"directions"]){
        DirectionsViewController *vc = (DirectionsViewController *)segue.destinationViewController;
        vc.directionsList = directionsList;
    }
    
}


//
//  set the right address field
//
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    if ([[segue identifier] isEqualToString:@"directions"])
        return;
    
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
        __weak ViewController* weakSelf;
        weakSelf = self;
        
        [self.geocoder geocodeAddressString:newAddr completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if(placemarks.count > 0) {
                
                CLPlacemark *bestResult = [placemarks objectAtIndex:0];
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:bestResult];
                [weakSelf.mapView addAnnotation:placemark];
                *locationAddress = bestResult.location;
                
                //
                //  see if we can calc distnce, zoom, and route
                //
                if (fromLocation && toLocation){
                    
                    float distance = [fromLocation distanceFromLocation:toLocation] * 0.000621371192;
                    weakSelf.messageLabel.text = [NSString stringWithFormat:@"Distance is %g miles", distance];
                    
                    [weakSelf zoomMapToRegionEncapsulatingLocation:fromLocation andLocation:toLocation];
                    [weakSelf directions:fromLocation andLocation:toLocation];
                    
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
//  generate directions from two points
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

    __weak ViewController* weakSelf;
    weakSelf = self;

    [directions calculateDirectionsWithCompletionHandler:
        ^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            } else {
                
                MKRoute* route = response.routes[0];
                float distance = route.distance * 0.000621371192;
                weakSelf.messageLabel.text = [NSString stringWithFormat:@"Drive is %g miles", distance];

                [weakSelf showRoute:response];
                
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
        
        directionsList = [[NSMutableArray alloc] init];
        for (MKRouteStep *step in route.steps)
        {
            [directionsList addObject:step.instructions];
        }
        
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


//
//  clear the map
//
-(IBAction)clearButtonClicked:(id)sender{
    
    directionsList = nil;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (id<MKOverlay> overlayToRemove in self.mapView.overlays)
    {
        if ([overlayToRemove isKindOfClass:[MKPolyline class]])
        {
            [self.mapView removeOverlay:overlayToRemove];
        }
    }
    
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    
    return UIModalPresentationNone;
    
}



@end
