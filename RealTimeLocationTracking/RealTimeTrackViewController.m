
#import "RealTimeTrackViewController.h"
#import "TrackService.h"
#import "TrackDetailModel.h"
#import "TrackLocationDetailModel.h"
@interface RealTimeTrackViewController ()<GetAutocompleteResultDelegate> {
    NSMutableArray *pathLatLongArray;
    CLLocationCoordinate2D sourceLocation;
    CLLocationCoordinate2D destinationLocation;
    NSString *driverUserId;
    NSDictionary *latLongDict;
    NSMutableArray *trackArray;
    NSMutableArray *locationDetailArray;
}
@property (weak, nonatomic) IBOutlet GoogleMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *databaseTrackingButton;
@property (weak, nonatomic) IBOutlet UIButton *serverTrackingButton;
@property (weak, nonatomic) IBOutlet UILabel *noRecordLabel;

@end

@implementation RealTimeTrackViewController
@synthesize locationManager;
@synthesize selectedMenu;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pathLatLongArray = [NSMutableArray new];
    trackArray=[[NSMutableArray alloc]init];
    locationDetailArray=[[NSMutableArray alloc]init];
    _mapView.delegate = _mapView;
    locationManager = [[LocationObject alloc]init];
    latLongDict = [[NSDictionary alloc]init];
    if (selectedMenu) {
        [myDelegate showIndicator];
        [self performSelector:@selector(fetchCurrentLocation) withObject:nil afterDelay:.1];
        
    } else {
        [self fetchRecordsFromDatabase];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Fetch current location
- (void)fetchCurrentLocation {
    locationManager.delegate=self;
    [locationManager getLocationInfo];
}

- (void)fetchRealTimeLocation:(float)latitude longitude:(float)longitude {
    NSLog(@"lat: %f, long: %f",latitude,longitude);
    [self getTrackDataService:latitude longitude:longitude];
}
#pragma mark - end

#pragma mark - Show path from Database
- (void)fetchRecordsFromDatabase {
    NSMutableArray *gpsInfo = [NSMutableArray new];
    NSString *query=[NSString stringWithFormat: @"SELECT * FROM LocationTracking WHERE userId = '%@' LIMIT 30",[UserDefaultManager getValue:@"userId"]];
    gpsInfo =[MyDatabase getDataFromLocationTable:[query UTF8String]];
    if (gpsInfo.count>0) {
        NSDictionary *dict = [NSDictionary new];
        for (int i=0; i<gpsInfo.count; i++) {
            dict = [gpsInfo objectAtIndex:i];
            NSString *pointString=[NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"latitude"],[dict objectForKey:@"longitude"]];
            NSLog(@"points string: %@",pointString);
            [pathLatLongArray addObject:pointString];
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
                locationManager.marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
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
    } else {
        _noRecordLabel.hidden = NO;
        _mapView.hidden = YES;
    }
    
}
#pragma mark - end

#pragma mark - Server track data
- (IBAction)serverTrackingAction:(id)sender {
    [self fetchCurrentLocation];
}

-(void)getTrackDataService:(float)latitude longitude:(float)longitude {
    [[TrackService sharedManager] getStoreTrackData:[NSString stringWithFormat:@"%f",latitude] longitude:[NSString stringWithFormat:@"%f",longitude] range:[NSString stringWithFormat:@"%d",1000] timeStamp:@"" success:^(id array) {
        trackArray=[array mutableCopy];
        [myDelegate stopIndicator];
        if (trackArray.count>=1) {
            for (int i=0; i<trackArray.count; i++) {
                NSString *userId = [[trackArray objectAtIndex:i]userId];
                NSLog(@"user id  = %@",userId);
                locationDetailArray = [[trackArray objectAtIndex:i]locationDetailsArray];
                [self displayServerData:[locationDetailArray lastObject]];
            }
        }
        else {
            _noRecordLabel.hidden = NO;
            _mapView.hidden = YES;
        }
    } failure:^(NSError *error) {
        NSLog(@"Please try again");
    }];
}

- (void)displayServerData:(TrackLocationDetailModel *)locationModel {
    NSLog(@"currentDateTime = %@, userId = %@, latitude = %f, longitude = %f, calculatedDistance = %d",locationModel.currentDateTime, locationModel.userId, locationModel.latitude, locationModel.longitude, locationModel.calculatedDistance);
    GMSMarker *mkr = [[GMSMarker alloc] init];
    if (locationModel.latitude !=0 && locationModel.longitude!=0) {
        [mkr setPosition:CLLocationCoordinate2DMake(locationModel.latitude, locationModel.longitude)];
        [mkr setMap:_mapView];
        mkr.appearAnimation=kGMSMarkerAnimationPop;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationModel.latitude longitude:locationModel.longitude zoom:15];
        _mapView.camera=camera;
    }
}
#pragma mark - end
@end
