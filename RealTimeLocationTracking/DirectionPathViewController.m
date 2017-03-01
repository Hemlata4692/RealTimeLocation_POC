//
//  DirectionPathViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 22/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DirectionPathViewController.h"

@interface DirectionPathViewController ()<getAutocompleteResultDelegate>
{
    CLLocationCoordinate2D sourceLocation;
    CLLocationCoordinate2D destinationLocation;
}
@property (weak, nonatomic) IBOutlet GoogleMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *sourceLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationLocationTextField;

@end

@implementation DirectionPathViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _locationManager = [[LocationObject alloc]init];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Display instant search results
    if ([_autoCompleteLocation isEqualToString:@"2"]) {
        
        sourceLocation.latitude = [_latitude floatValue];
        sourceLocation.longitude = [_longitude floatValue];
        _locationManager.delegate=self;
        [_locationManager getAddressMethod:sourceLocation isDirectionScreen:YES];
    }
    
    // hide navigation bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_sourceLocationTextField endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    _locationManager.marker.position = locationCoordinate;
    _locationManager.marker.title = @"Address";
    _locationManager.marker.snippet = userAddress;
    _sourceLocationTextField.text=_locationManager.marker.snippet;
    _locationManager.marker.map= _mapView;
    
}
#pragma mark - end

#pragma mark - Textfield delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if(textField == _sourceLocationTextField) {
        
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SelectPlaceViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"SelectPlaceViewController"];
        pushView.isDirectionView = true;
        pushView.DirectionViewObj=self;
        [self.navigationController pushViewController:pushView animated:NO];
        
    } else {
        
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Get directions
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
- (IBAction)getDirectionAction:(id)sender {
    
    [_sourceLocationTextField resignFirstResponder];
    [_destinationLocationTextField resignFirstResponder];

    if([self performValidationsForGetDirectionPath]) {
        
        [myDelegate showIndicator];
        [self getLatLongFromArray:_destinationLocationTextField.text];
    }
    
}
-(void)getLatLongFromArray:(NSString *)addressString {
    
    _locationManager.delegate = self;
    [_locationManager fetchLatitudeLongitudeFromAddress:addressString];
    
}
//Display destination location results
-(void)returnAutocompleteSearchResults:(NSDictionary *)jsonResult isSearchValue:(BOOL)isSearchValue {
    
    NSArray *locationArray = [NSArray new];
    locationArray = [jsonResult objectForKey:@"results"];
    [self parseLatLongFromArray:[locationArray objectAtIndex:0]];
    
}

- (void)parseLatLongFromArray:(NSDictionary *)locationDict {
    
    NSDictionary *tempDict=locationDict[@"geometry"];
    NSDictionary * latLongDict =tempDict[@"location"];
    destinationLocation.latitude=[latLongDict[@"lat"] floatValue];
    destinationLocation.longitude=[latLongDict[@"lng"] floatValue];
    
    [_locationManager fetchDirectionPathResults:sourceLocation destinationLocation:destinationLocation];
    
}
-(void)returnDirectionResults:(NSDictionary *)jsonResult {
    
    [myDelegate stopIndicator];
    
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
    
    _mapView.camera = camera;
    _locationManager.marker.position = sourceLocation;
    _locationManager.marker.title = @"Source Address";
    _locationManager.marker.snippet = sourceAddress;
    _sourceLocationTextField.text=_locationManager.marker.snippet;
    _locationManager.marker.map= _mapView;
    
    _mapView.camera = camera;
    _locationManager.destinationMarker.position = destinationLocation;
    _locationManager.destinationMarker.title = @"Destination Address";
    _locationManager.destinationMarker.snippet = destinationAddress;
    _destinationLocationTextField.text=_locationManager.destinationMarker.snippet;
    _locationManager.destinationMarker.map= _mapView;
    
    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
    singleLine.strokeWidth = 4;
    singleLine.strokeColor = [UIColor blueColor];
    singleLine.map = _mapView;
    
}
#pragma mark - end

#pragma mark - Show alert
-(void)showAlertTextMessage:(NSString *)alertMessage {
    
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
