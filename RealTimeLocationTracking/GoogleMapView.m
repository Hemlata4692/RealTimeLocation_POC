//
//  GoogleMapView.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 21/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GoogleMapView.h"

@implementation GoogleMapView
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - Drag and drop pin delegate method
- (void) mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)googlemarker {
    NSLog(@"didEndDraggingMarker");
    _locationManager = [[LocationObject alloc]init];
    [_locationManager getAddressMethod:googlemarker.position];
}

#pragma mark - Long press delegate method
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"didLongPressAtCoordinate");
    _locationManager = [[LocationObject alloc]init];
    [_locationManager getAddressMethod:coordinate];
}
#pragma mark - end
@end
