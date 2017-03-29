
#import "RealTimeTrackViewController.h"

@interface RealTimeTrackViewController ()<GetAutocompleteResultDelegate> {
    NSMutableArray *pathLatLongArray;
    CLLocationCoordinate2D sourceLocation;
    CLLocationCoordinate2D destinationLocation;
    NSTimer *currentLocationTrackTimer;
}
@property (weak, nonatomic) IBOutlet GoogleMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *selfTrackingButton;

@end

@implementation RealTimeTrackViewController
@synthesize locationManager;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pathLatLongArray = [NSMutableArray new];
    _mapView.delegate = _mapView;
    locationManager = [[LocationObject alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Background tracking
    if ([UserDefaultManager getValue:@"isRealTimeTrackingStart"] == NULL || [[UserDefaultManager getValue:@"isRealTimeTrackingStart"] isEqualToString:@"false"]) {
        _selfTrackingButton.selected = NO;
        [_selfTrackingButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    else {
        _selfTrackingButton.selected = YES;
        [_selfTrackingButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}
#pragma mark - end

#pragma mark - Show path from DB
- (IBAction)fetchData:(id)sender {
    //Fetch database records
    [self fetchRecords];
}

- (void)fetchRecords {
    NSMutableArray *gpsInfo = [NSMutableArray new];
    NSString *query=[NSString stringWithFormat:@"SELECT * FROM LocationTracking "];
    gpsInfo =[MyDatabase getDataFromLocationTable:[query UTF8String]];
    if (gpsInfo.count>0) {
        NSDictionary *dict = [NSDictionary new];
        for (int i=0; i<gpsInfo.count; i++) {
            dict = [gpsInfo objectAtIndex:i];
            NSString *pointString=[NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"latitude"],[dict objectForKey:@"longitude"]];
            NSLog(@"points string: %@",pointString);
            [pathLatLongArray addObject:pointString];
            GMSMarker *mkr = [[GMSMarker alloc] init];
            if ([dict objectForKey:@"latitude"] !=0 && [dict objectForKey:@"longitude"]!=0) {
                [mkr setPosition:CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] floatValue], [[dict objectForKey:@"longitude"] floatValue])];
                [mkr setMap:_mapView];
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[dict objectForKey:@"latitude"] floatValue] longitude:[[dict objectForKey:@"longitude"] floatValue] zoom:5];
                _mapView.camera=camera;
            }
            GMSMutablePath *path = [GMSMutablePath path];
            for (int i=0; i<pathLatLongArray.count; i++) {
                NSArray *latlongArray = [[pathLatLongArray objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
            }
            if (pathLatLongArray.count>2) {
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                polyline.strokeColor = [UIColor blueColor];
                polyline.strokeWidth = 4.f;
                polyline.map = _mapView;
            }
            //Show marker on locations
            if (i == 0) {
                NSString *pointString=[NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"latitude"],[dict objectForKey:@"longitude"]];
                NSLog(@"source: %@",pointString);
                NSArray *latlongArray = [[pathLatLongArray objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latlongArray objectAtIndex:0] doubleValue]  longitude:[[latlongArray objectAtIndex:1] doubleValue] zoom:15];
                sourceLocation.latitude = [[latlongArray objectAtIndex:0] doubleValue];
                sourceLocation.longitude = [[latlongArray objectAtIndex:1] doubleValue];
                _mapView.camera = camera;
                locationManager.marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
                locationManager.marker.position = sourceLocation;
                locationManager.marker.map= _mapView;
                
            } else if (i == gpsInfo.count - 1) {
                NSString *pointString=[NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"latitude"],[dict objectForKey:@"longitude"]];
                NSLog(@"destination: %@",pointString);
                NSArray *latlongArray = [[pathLatLongArray objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latlongArray objectAtIndex:0] doubleValue]  longitude:[[latlongArray objectAtIndex:1] doubleValue] zoom:15];
                destinationLocation.latitude = [[latlongArray objectAtIndex:0] doubleValue];
                destinationLocation.longitude = [[latlongArray objectAtIndex:1] doubleValue];
                _mapView.camera = camera;
                locationManager.destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                locationManager.destinationMarker.position = destinationLocation;
                locationManager.destinationMarker.map= _mapView;
            }
        }
    }
}
#pragma mark - end

#pragma mark - Self tracking
- (IBAction)trackingWithCurrentLocation:(id)sender {
    if (_selfTrackingButton.selected) {
        [UserDefaultManager setValue:@"false" key:@"isRealTimeTrackingStart"];
        [locationManager stopRealTimeTracking];
        _selfTrackingButton.selected = NO;
        [_selfTrackingButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    else {
        [UserDefaultManager setValue:@"true" key:@"isRealTimeTrackingStart"];
        _selfTrackingButton.selected = YES;
        [_selfTrackingButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self fetchCurrentLocation];
    }
}
#pragma mark - end

#pragma mark - Show location on marker
- (void)fetchCurrentLocation {
    locationManager.delegate=self;
    [locationManager startRealTimeTracking:10 dist:0];
}

- (void)fetchRealTimeLocation:(float)latitude longitude:(float)longitude {
    NSLog(@"lat: %f, long: %f",latitude,longitude);
    NSString *pointString=[NSString stringWithFormat:@"%f,%f",latitude,longitude];
    [pathLatLongArray addObject:pointString];
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<pathLatLongArray.count; i++) {
        NSArray *latlongArray = [[pathLatLongArray   objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
    }
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude  longitude:longitude zoom:17];
    _mapView.camera = camera;
    if (pathLatLongArray.count>2) {
        //Show path between two locations
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeColor = [UIColor blueColor];
        polyline.strokeWidth = 5.f;
        polyline.map = _mapView;
    }
    //Show marker on start location
    if ([pathLatLongArray firstObject]) {
        NSArray *latlongArray = [[pathLatLongArray objectAtIndex:0]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latlongArray objectAtIndex:0] doubleValue]  longitude:[[latlongArray objectAtIndex:1] doubleValue] zoom:15];
        sourceLocation.latitude = [[latlongArray objectAtIndex:0] doubleValue];
        sourceLocation.longitude = [[latlongArray objectAtIndex:1] doubleValue];
        _mapView.camera = camera;
        locationManager.marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        locationManager.marker.position = sourceLocation;
        locationManager.marker.map= _mapView;
    }
    //Show marker on moving destination location
    if ([pathLatLongArray lastObject]) {
        NSArray *latlongArray = [[pathLatLongArray lastObject]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latlongArray objectAtIndex:0] doubleValue]  longitude:[[latlongArray objectAtIndex:1] doubleValue] zoom:15];
        destinationLocation.latitude = [[latlongArray objectAtIndex:0] doubleValue];
        destinationLocation.longitude = [[latlongArray objectAtIndex:1] doubleValue];
        _mapView.camera = camera;
        locationManager.destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        locationManager.destinationMarker.position = destinationLocation;
        locationManager.destinationMarker.map= _mapView;
    }
}
#pragma mark - end
@end
