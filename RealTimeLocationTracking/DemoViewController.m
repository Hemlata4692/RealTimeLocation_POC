//
//  DemoViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DemoViewController.h"
#import "MapViewController.h"
#import "LoginViewController.h"
@interface DemoViewController () {
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
    UIViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    [self.navigationController pushViewController:pushView animated:YES];
}
#pragma mark - end

#pragma mark - Empty database
- (IBAction)emptyDatabaseAction:(id)sender {
    [MyDatabase deleteRecord:[@"delete from LocationTracking" UTF8String]];
 }
#pragma mark - end
- (IBAction)logoutAction:(id)sender {
    [UserDefaultManager removeValue:@"userId"];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController * loginView = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController setViewControllers: [NSArray arrayWithObject:loginView]
                                         animated: NO];
}
@end
