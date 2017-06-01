//
//  PathTrackingViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 03/05/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "PathTrackingViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface PathTrackingViewController ()<GMSMapViewDelegate> {
    NSMutableArray *pathLatLongArray;
    CLLocationCoordinate2D sourceLocation;
    CLLocationCoordinate2D destinationLocation;
    NSTimer *localTrackingTimer;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapview;
@property (weak, nonatomic) IBOutlet UIButton *trackingButton;

@end

@implementation PathTrackingViewController
@synthesize locationManager;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapview.delegate=self;
    locationManager = [[LocationObject alloc]init];
    pathLatLongArray = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Background tracking
    if ([UserDefaultManager getValue:@"isRealTimeTrackingStart"] == NULL || [[UserDefaultManager getValue:@"isRealTimeTrackingStart"] isEqualToString:@"false"]) {
        _trackingButton.selected = NO;
        [_trackingButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    else {
        _trackingButton.selected = YES;
        [_trackingButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self fetchRecordsFromDatabase];
        [self startLocalTrackingTimer];
        
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self stopTimer];
}
#pragma mark - end

#pragma mark - Show route path
- (IBAction)selfPathTrackingButtonAction:(id)sender {
    if (_trackingButton.selected) {
        [UserDefaultManager setValue:@"false" key:@"isRealTimeTrackingStart"];
        [locationManager stopRealTimeTracking];
        [self stopTimer];
        _trackingButton.selected = NO;
        [_trackingButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    else {
        [UserDefaultManager setValue:@"true" key:@"isRealTimeTrackingStart"];
        _trackingButton.selected = YES;
        [_trackingButton setTitle:@"Stop" forState:UIControlStateNormal];
        [locationManager startRealTimeTracking:05 dist:0];
        [self startLocalTrackingTimer];
    }
}

- (void)fetchRecordsFromDatabase {
    NSMutableArray *gpsInfo = [NSMutableArray new];
    NSString *query=[NSString stringWithFormat:@"SELECT * FROM SelfLocationTracking "];
    gpsInfo =[MyDatabase getDataFromLocationTable:[query UTF8String]];
    if (gpsInfo.count>0) {
        NSDictionary *dict = [NSDictionary new];
        for (int i=0; i<gpsInfo.count; i++) {
            dict = [gpsInfo objectAtIndex:i];
            NSString *pointString=[NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"latitude"],[dict objectForKey:@"longitude"]];
            NSLog(@"points string: %@",pointString);
            [pathLatLongArray addObject:pointString];
            [self show:pathLatLongArray];
        }
    }
}

-(void) show:(NSMutableArray *)pathLatLongArray1 {
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<pathLatLongArray1.count; i++) {
        NSArray *latlongArray = [[pathLatLongArray1   objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
    }
    if (pathLatLongArray1.count>2) {
        //Show path between two locations
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeColor = [UIColor blueColor];
        polyline.strokeWidth = 5.f;
        polyline.map = _mapview;
    }
    //Show marker on start location
    if ([pathLatLongArray1 firstObject]) {
        NSArray *latlongArray = [[pathLatLongArray1 objectAtIndex:0]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latlongArray objectAtIndex:0] doubleValue]  longitude:[[latlongArray objectAtIndex:1] doubleValue] zoom:15];
        sourceLocation.latitude = [[latlongArray objectAtIndex:0] doubleValue];
        sourceLocation.longitude = [[latlongArray objectAtIndex:1] doubleValue];
        _mapview.camera = camera;
        locationManager.marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        locationManager.marker.position = sourceLocation;
        locationManager.marker.map= _mapview;
    }
    //Show marker on moving destination location
    if ([pathLatLongArray1 lastObject]) {
        NSArray *latlongArray = [[pathLatLongArray1 lastObject]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latlongArray objectAtIndex:0] doubleValue]  longitude:[[latlongArray objectAtIndex:1] doubleValue] zoom:15];
        destinationLocation.latitude = [[latlongArray objectAtIndex:0] doubleValue];
        destinationLocation.longitude = [[latlongArray objectAtIndex:1] doubleValue];
        _mapview.camera = camera;
        locationManager.destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        locationManager.destinationMarker.position = destinationLocation;
        locationManager.destinationMarker.map= _mapview;
    }
}

#pragma mark - end

#pragma mark - Location timer
- (void) startLocalTrackingTimer {
    if (![localTrackingTimer isValid]) {
        localTrackingTimer = [NSTimer scheduledTimerWithTimeInterval: 10                                                                                target: self selector: @selector(fetchRecordsFromDatabase) userInfo: nil repeats: YES];
    }
}

- (void) stopTimer {
    [localTrackingTimer invalidate];
    localTrackingTimer = nil;
}
#pragma mark - end
@end
