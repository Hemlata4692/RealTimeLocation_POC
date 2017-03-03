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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showMapScreenAction:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapViewController *nextView =[storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self.navigationController pushViewController:nextView animated:YES];
    
}
- (IBAction)fetchRecords:(id)sender {
    
//     [MyDatabase deleteRecord:[@"delete from LocationTracking" UTF8String]];
    
    NSMutableArray *gpsInfo = [NSMutableArray new];
    
    NSString *query=[NSString stringWithFormat:@"SELECT * FROM LocationTracking "];
    gpsInfo =[MyDatabase getDataFromLocationTable:[query UTF8String]];
    
    if (gpsInfo.count>0)
    {
        NSDictionary *dict = [NSDictionary new];
        NSMutableArray *latArray = [NSMutableArray new];
        NSMutableArray *longArray = [NSMutableArray new];

        for (int i=0; i<gpsInfo.count; i++) {
            
            
                     dict = [gpsInfo objectAtIndex:i];

            latArray = [dict objectForKey:@"latitude"];
            longArray = [dict objectForKey:@"longitude"];

            NSString *pointString=[NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"latitude"],[dict objectForKey:@"longitude"]];
            
            NSLog(@"points string: %@",pointString);
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
        }
        
//        [[CampaignService sharedManager] setGPSTrackDataService:gpsInfo success :^(id responseObject)
//         {
//             [MyDatabase deleteRecord:[@"delete from LocationTracking" UTF8String]];
//         }
//                                                        failure:^(NSError *error)
//         {
//             
//         }];
    }
    
    
}

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
