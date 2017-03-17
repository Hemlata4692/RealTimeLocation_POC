//
//  DemoViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DemoViewController.h"
#import "MapViewController.h"
@interface DemoViewController ()
{
    BOOL isLocationUpdateStart;
}
@end

@implementation DemoViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Show google map screen
- (IBAction)showMapScreenAction:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapViewController *nextView =[storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self.navigationController pushViewController:nextView animated:YES];
    
}
#pragma mark - end

#pragma mark - Fetch database records
- (IBAction)fetchRecords:(id)sender {
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"RealTimeTrackViewController"];
    [self.navigationController pushViewController:pushView animated:NO];
}
#pragma mark - end

#pragma mark - Empty database
- (IBAction)emptyDatabaseAction:(id)sender {
    
    [MyDatabase deleteRecord:[@"delete from LocationTracking" UTF8String]];
}
#pragma mark - end

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//
//    NSString *pointString=[NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
//    [self.points addObject:pointString];
//    GMSMutablePath *path = [GMSMutablePath path];
//    for (int i=0; i<self.points.count; i++)
//    {
//        NSArray *latlongArray = [[self.points   objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
//
//        [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
//    }
//
//    if (self.points.count>2)
//    {
//        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
//        polyline.strokeColor = [UIColor blueColor];
//        polyline.strokeWidth = 5.f;
//        polyline.map = mapView_;
//        self.view = mapView_;
//    }
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
