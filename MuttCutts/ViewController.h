//
//  ViewController.h
//  MuttCutts
//
//  Created by Tom Williamson on 4/29/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton* fromAddressButton;
@property (weak, nonatomic) IBOutlet UIButton* toAddressButton;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;

@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end

