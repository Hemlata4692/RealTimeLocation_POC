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
    [_locationManager getAddressMethod:googlemarker.position isDirectionScreen:NO];
}

#pragma mark - Long press delegate method
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"didLongPressAtCoordinate");
    _locationManager = [[LocationObject alloc]init];
    [_locationManager getAddressMethod:coordinate isDirectionScreen:NO];
}
#pragma mark - end
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
}

- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay{
    
    NSString *path = overlay.title;
    
    //Finding componentpaths of string
    NSArray *pathparts = [path pathComponents];
    NSString *lat = [pathparts objectAtIndex:0];
    NSString *lng = [pathparts objectAtIndex:1];
    NSString *linkID = [pathparts objectAtIndex:2];
    
    //Here we are building a marker to place near the users tap location on the polyline.
    GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([lat doubleValue],[lng doubleValue])];
    marker.title = overlay.title;
    marker.snippet = @"ROUTE DATA";
    marker.map = self;
    
    //This will popup a marker window
//    [self.googleMapView setSelectedMarker:marker];
}
@end
