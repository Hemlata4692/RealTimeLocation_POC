//
//  GoogleMapView.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 21/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
@interface GoogleMapView : GMSMapView<GMSMapViewDelegate>

@property (nonatomic, strong) LocationObject *locationManager;

@end
