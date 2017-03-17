//
//  MapViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 20/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "MapViewController.h"
@interface MapViewController ()
{
    CLLocationCoordinate2D currentLocation;
}

@property (weak, nonatomic) IBOutlet GoogleMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *trackingButton;

@end

@implementation MapViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize location manager class
    _locationManager = [[LocationObject alloc]init];
    
    //Initialize google map delegate
    _googleMapView.delegate = _googleMapView;
    
    //Set map view type
    //        _googleMapView.mapType=kGMSTypeSatellite;
    
    //Fetch current location
    [self fetchCurrentLocation];
    
    //Show fetched address
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPinOnLcation:) name:@"newLocationAddress" object:nil];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Display instant search results
    if ([_otherLocation isEqualToString:@"1"]) {
        
        currentLocation.latitude = [_latitude floatValue];
        currentLocation.longitude = [_longitude floatValue];
        [_locationManager getAddressMethod:currentLocation isDirectionScreen:NO];
    }
    
    // hide navigation bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    //Background tracking
    if ([UserDefaultManager getValue:@"isTrackingStart"] == NULL || [[UserDefaultManager getValue:@"isTrackingStart"] isEqualToString:@"false"])
    {
        _trackingButton.selected = NO;
        [_trackingButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    else
    {
        _trackingButton.selected = YES;
        [_trackingButton setTitle:@"Stop" forState:UIControlStateNormal];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchTextField endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Post notification(receive location)
- (void)showPinOnLcation:(NSNotification *)notification {
    NSLog(@"notification received: %@",notification.userInfo);
    
    currentLocation.latitude = [[notification.userInfo objectForKey:@"latitude"] doubleValue];
    currentLocation.longitude = [[notification.userInfo objectForKey:@"longitude"] doubleValue];
    NSString *address = [notification.userInfo objectForKey:@"locationAddress"];
    _googleMapView.camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude
                                                        longitude:currentLocation.longitude
                                                             zoom:14];
    [self displayLocationOnMap:currentLocation camera:_googleMapView.camera userAddress:address];
}
#pragma mark - end

#pragma mark - Show location on marker
- (void)fetchCurrentLocation {
    [_locationManager getLocationInfo];
}
- (void)displayLocationOnMap:(CLLocationCoordinate2D)locationCoordinate camera:(GMSCameraPosition *)camera userAddress:(NSString *)userAddress {
    
    _googleMapView.camera = camera;
    currentLocation = locationCoordinate;
    _locationManager.marker.position = locationCoordinate;
    _locationManager.marker.title = @"Address";
    _locationManager.marker.snippet = userAddress;
    _searchTextField.text=_locationManager.marker.snippet;
    _locationManager.marker.tappable = true;
    _locationManager.marker.map= _googleMapView;
    _locationManager.marker.draggable = true;
    
}
#pragma mark - end

#pragma mark - Start background location updates
- (IBAction)startLocationTrackingAction:(id)sender {
    
    if (_trackingButton.selected) {
        
        _trackingButton.selected = NO;
        [_trackingButton setTitle:@"Start" forState:UIControlStateNormal];
        [UserDefaultManager setValue:@"false" key:@"isTrackingStart"];
        [_locationManager stopTrack];

    }
    else {
        
        _trackingButton.selected = YES;
        [_trackingButton setTitle:@"Stop" forState:UIControlStateNormal];
        [UserDefaultManager setValue:@"true" key:@"isTrackingStart"];
        [_locationManager startTrack:10 dist:0];

    }
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectPlaceViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"SelectPlaceViewController"];
    pushView.isDirectionView = false;
    pushView.MapViewObj=self;
    [self.navigationController pushViewController:pushView animated:YES];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Get directions
- (IBAction)getDirectionButtonAction:(id)sender {
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"DirectionPathViewController"];
    [self.navigationController pushViewController:pushView animated:YES];
    
}
#pragma mark - end

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
