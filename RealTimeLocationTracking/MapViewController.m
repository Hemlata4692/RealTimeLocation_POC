
#import "MapViewController.h"
@interface MapViewController ()<GetAutocompleteResultDelegate>{
    CLLocationCoordinate2D currentLocation;
    CLLocationCoordinate2D destinationLocation;
    int isDestinationFieldVisible;
    GMSPath *path;
}

@property (weak, nonatomic) IBOutlet GoogleMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UIButton *trackingButton;
@property (weak, nonatomic) IBOutlet UIButton *rideNowButton;

@end

@implementation MapViewController
@synthesize latitude;
@synthesize longitude;
@synthesize otherLocation;
@synthesize locationManager;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Initialize location manager class
    locationManager = [[LocationObject alloc]init];
    //Initialize google map delegate
    _googleMapView.delegate = _googleMapView;
    //Set map view type
    //_googleMapView.mapType=kGMSTypeSatellite;
    //Fetch current location
    [self fetchCurrentLocation];
    //Show fetched address
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPinOnLcation:) name:@"newLocationAddress" object:nil];
    [self addMenuButton];
    [self setCornerRadius];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Display instant search results
    if ([otherLocation isEqualToString:@"1"]) {
        destinationLocation.latitude = [latitude floatValue];
        destinationLocation.longitude = [longitude floatValue];
        locationManager.delegate = self;
        [locationManager fetchDirectionPathResults:currentLocation destinationLocation:destinationLocation];
    }
    //Hide navigation bar
    self.navigationItem.title = @"Where to go ?";
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    //    //Background tracking
    //    if ([UserDefaultManager getValue:@"isTrackingStart"] == NULL || [[UserDefaultManager getValue:@"isTrackingStart"] isEqualToString:@"false"]) {
    //        _trackingButton.selected = NO;
    //        [_trackingButton setTitle:@"Start location tracking" forState:UIControlStateNormal];
    //    }
    //    else {
    //        _trackingButton.selected = YES;
    //        [_trackingButton setTitle:@"Stop location tracking" forState:UIControlStateNormal];
    //    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchTextField endEditing:YES];
    [_destinationTextField endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setCornerRadius {
    [_searchTextField addShadow:_searchTextField color:[UIColor lightGrayColor]];
    [_destinationTextField addShadow:_destinationTextField color:[UIColor lightGrayColor]];
}
#pragma mark - end

#pragma mark - Post notification(receive location)
- (void)showPinOnLcation:(NSNotification *)notification {
    NSLog(@"notification received: %@",notification.userInfo);
    //Show pin on current location
    currentLocation.latitude = [[notification.userInfo objectForKey:@"latitude"] doubleValue];
    currentLocation.longitude = [[notification.userInfo objectForKey:@"longitude"] doubleValue];
    NSString *address = [notification.userInfo objectForKey:@"locationAddress"];
    _googleMapView.camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude
                                                        longitude:currentLocation.longitude
                                                             zoom:14];
    [self displayLocationOnMap:currentLocation userAddress:address];
}
#pragma mark - end

#pragma mark - Show location on marker
- (void)fetchCurrentLocation {
    [locationManager getLocationInfo];
}

- (void)displayLocationOnMap:(CLLocationCoordinate2D)locationCoordinate userAddress:(NSString *)userAddress {
    //Display current location with marker
    _googleMapView.camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude
                                                        longitude:currentLocation.longitude
                                                             zoom:14];
    currentLocation = locationCoordinate;
    locationManager.marker.position = locationCoordinate;
    locationManager.marker.title = @"Address";
    locationManager.marker.snippet = userAddress;
    _searchTextField.text=locationManager.marker.snippet;
    locationManager.marker.tappable = true;
    locationManager.marker.map= _googleMapView;
    locationManager.marker.draggable = true;
}
#pragma mark - end

#pragma mark - Start background location updates
//- (IBAction)startLocationTrackingAction:(id)sender {
//    if (_trackingButton.selected) {
//        _trackingButton.selected = NO;
//        [_trackingButton setTitle:@"Start location tracking" forState:UIControlStateNormal];
//        [UserDefaultManager setValue:@"false" key:@"isTrackingStart"];
//        [locationManager stopTrack];
//    }
//    else {
//        _trackingButton.selected = YES;
//        [_trackingButton setTitle:@"Stop location tracking" forState:UIControlStateNormal];
//        [UserDefaultManager setValue:@"true" key:@"isTrackingStart"];
//        [locationManager startTrack:10 serverSyncTime:60 dist:0];
//    }
//}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _destinationTextField) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SelectPlaceViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"SelectPlaceViewController"];
        pushView.isDirectionView = false;
        pushView.mapViewObj=self;
        [self.navigationController pushViewController:pushView animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == _searchTextField) {
        [myDelegate showIndicator];
        [self getLatLongFromArray:_searchTextField.text];
    }
    return YES;
}

//Get lat long from address string
- (void)getLatLongFromArray:(NSString *)addressString {
    locationManager.delegate = self;
    [locationManager fetchLatitudeLongitudeFromAddress:addressString];
}

//Display destination location results
- (void)returnAutocompleteSearchResults:(NSDictionary *)jsonResult isSearchValue:(BOOL)isSearchValue {
    NSArray *locationArray = [NSArray new];
    locationArray = [jsonResult objectForKey:@"results"];
    [self parseLatLongFromArray:[locationArray objectAtIndex:0]];
}

//Fetch lat long from locationlocation dictionary
- (void)parseLatLongFromArray:(NSDictionary *)locationDict {
    NSDictionary *tempDict=locationDict[@"geometry"];
    NSDictionary * latLongDict =tempDict[@"location"];
    currentLocation.latitude=[latLongDict[@"lat"] floatValue];
    currentLocation.longitude=[latLongDict[@"lng"] floatValue];
    _searchTextField.text = [locationDict objectForKey:@"formatted_address"];
    [self displayLocationOnMap:currentLocation userAddress:[locationDict objectForKey:@"formatted_address"]];
    [myDelegate stopIndicator];
}
#pragma mark - end

#pragma mark - Get directions
- (IBAction)getDirectionButtonAction:(id)sender {
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"DirectionPathViewController"];
    [self.navigationController pushViewController:pushView animated:YES];
}
#pragma mark - end

#pragma mark - Request a ride validation
- (BOOL)performValidationsForRequestRide{
    if ([_searchTextField isEmpty]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showWarning:self title:@"Alert" subTitle:@"Please select your pick up location." closeButtonTitle:@"Done" duration:0.0f];
        return NO;
    } else  if ([_destinationTextField isEmpty]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showWarning:self title:@"Alert" subTitle:@"Please select your destination location." closeButtonTitle:@"Done" duration:0.0f];
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - Request a ride
- (IBAction)requestRideAction:(id)sender {
    if (isDestinationFieldVisible == 0) {
        isDestinationFieldVisible = 1;
        _destinationTextField.hidden = NO;
    } else {
        if([self performValidationsForRequestRide]) {
            //Display path between the two locations
            [_rideNowButton setTitle:@"Ride Now" forState:UIControlStateNormal];
            GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
            singleLine.strokeWidth = 4;
            singleLine.strokeColor = [UIColor blueColor];
            singleLine.map = _googleMapView;
            //        [myDelegate showIndicator];
            //        [self performSelector:@selector(loginUser) withObject:nil afterDelay:.1];
        }
    }
}
#pragma mark - end

#pragma mark - Get directions
//Display path between two locations
- (void)returnDirectionResults:(NSDictionary *)jsonResult {
    [myDelegate stopIndicator];
    //Fetch distance and duration between two locations
    path =[GMSPath pathFromEncodedPath:jsonResult[@"routes"][0][@"overview_polyline"][@"points"]];
    NSDictionary *arr=jsonResult[@"routes"][0][@"legs"];
    NSMutableArray *loc=[[NSMutableArray alloc]init];
    NSString *dis,*dur;
    loc=[[arr valueForKey:@"distance"]valueForKey:@"text"];
    dis=loc[0];
    loc=[[arr valueForKey:@"duration"]valueForKey:@"text"];
    dur=loc[0];
    NSString *sourceAddress,*destinationAddress;
    loc=[arr valueForKey:@"start_address"];
    sourceAddress=loc[0];
    loc=[arr valueForKey:@"end_address"];
    destinationAddress=loc[0];
    [self showAlertTextMessage:[NSString stringWithFormat:@"Distance:%@ \nDuration:%@",dis,dur]];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude  longitude:currentLocation.longitude zoom:12 ];
    //Display source location on marker
    _googleMapView.camera = camera;
    locationManager.marker.position = currentLocation;
    locationManager.marker.title = @"Source Address";
    locationManager.marker.snippet = sourceAddress;
    _searchTextField.text=locationManager.marker.snippet;
    locationManager.marker.map= _googleMapView;
    //Display destination location on marker
    _googleMapView.camera = camera;
    locationManager.destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    locationManager.destinationMarker.position = destinationLocation;
    locationManager.destinationMarker.title = @"Destination Address";
    locationManager.destinationMarker.snippet = destinationAddress;
    _destinationTextField.text=locationManager.destinationMarker.snippet;
    locationManager.destinationMarker.map= _googleMapView;
    [_rideNowButton setTitle:@"Request a Ride" forState:UIControlStateNormal];
}
#pragma mark - end

#pragma mark - Show alert
- (void)showAlertTextMessage:(NSString *)alertMessage {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - end

@end
