
#import "DirectionPathViewController.h"

@interface DirectionPathViewController ()<GetAutocompleteResultDelegate> {
    CLLocationCoordinate2D sourceLocation;
    CLLocationCoordinate2D destinationLocation;
}
@property (weak, nonatomic) IBOutlet GoogleMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *sourceLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationLocationTextField;

@end

@implementation DirectionPathViewController
@synthesize locationManager;
@synthesize latitude;
@synthesize longitude;
@synthesize autoCompleteLocation;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[LocationObject alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Display instant search results
    if ([autoCompleteLocation isEqualToString:@"2"]) {
        sourceLocation.latitude = [latitude floatValue];
        sourceLocation.longitude = [longitude floatValue];
        locationManager.delegate=self;
        [locationManager getAddressMethod:sourceLocation isDirectionScreen:YES];
    }
    //Hide navigation bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_sourceLocationTextField endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - end

#pragma mark - Show pin on source location
- (void)showPinOnLcation:(NSDictionary *)locationData {
    sourceLocation.latitude = [[locationData objectForKey:@"latitude"] doubleValue];
    sourceLocation.longitude = [[locationData objectForKey:@"longitude"] doubleValue];
    NSString *address = [locationData objectForKey:@"locationAddress"];
    _mapView.camera = [GMSCameraPosition cameraWithLatitude:sourceLocation.latitude
                                                  longitude:sourceLocation.longitude
                                                       zoom:14];
    [self displayLocationOnMap:sourceLocation camera:_mapView.camera userAddress:address];
}
#pragma mark - end

#pragma mark - Show source location on marker
- (void)displayLocationOnMap:(CLLocationCoordinate2D)locationCoordinate camera:(GMSCameraPosition *)camera userAddress:(NSString *)userAddress {
    _mapView.camera = camera;
    sourceLocation = locationCoordinate;
    locationManager.marker.position = locationCoordinate;
    locationManager.marker.title = @"Address";
    locationManager.marker.snippet = userAddress;
    _sourceLocationTextField.text=locationManager.marker.snippet;
    locationManager.marker.map= _mapView;
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(textField == _sourceLocationTextField) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SelectPlaceViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"SelectPlaceViewController"];
        pushView.isDirectionView = true;
        pushView.DirectionViewObj=self;
        [self.navigationController pushViewController:pushView animated:NO];
    } else {
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Validation
- (BOOL)performValidationsForGetDirectionPath{
    if ([_sourceLocationTextField isEmpty]) {
        [self showAlertTextMessage:@"Please enter source location."];
        return NO;
    } else if ([_destinationLocationTextField isEmpty]) {
        [self showAlertTextMessage:@"Please enter destination location."];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - Get directions
//Get directions between two locations
- (IBAction)getDirectionAction:(id)sender {
    [_sourceLocationTextField resignFirstResponder];
    [_destinationLocationTextField resignFirstResponder];
    if([self performValidationsForGetDirectionPath]) {
        [myDelegate showIndicator];
        [self getLatLongFromArray:_destinationLocationTextField.text];
    }
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
    destinationLocation.latitude=[latLongDict[@"lat"] floatValue];
    destinationLocation.longitude=[latLongDict[@"lng"] floatValue];
    [locationManager fetchDirectionPathResults:sourceLocation destinationLocation:destinationLocation];
}

//Display path between two locations
- (void)returnDirectionResults:(NSDictionary *)jsonResult {
    [myDelegate stopIndicator];
    //Fetch distance and duration between two locations
    GMSPath *path =[GMSPath pathFromEncodedPath:jsonResult[@"routes"][0][@"overview_polyline"][@"points"]];
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:sourceLocation.latitude  longitude:sourceLocation.longitude zoom:7];
    //Display source location on marker
    _mapView.camera = camera;
    locationManager.marker.position = sourceLocation;
    locationManager.marker.title = @"Source Address";
    locationManager.marker.snippet = sourceAddress;
    _sourceLocationTextField.text=locationManager.marker.snippet;
    locationManager.marker.map= _mapView;
    //Display destination location on marker
    _mapView.camera = camera;
    locationManager.destinationMarker.position = destinationLocation;
    locationManager.destinationMarker.title = @"Destination Address";
    locationManager.destinationMarker.snippet = destinationAddress;
    _destinationLocationTextField.text=locationManager.destinationMarker.snippet;
    locationManager.destinationMarker.map= _mapView;
    //Display path between the two locations
    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
    singleLine.strokeWidth = 4;
    singleLine.strokeColor = [UIColor blueColor];
    singleLine.map = _mapView;
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
