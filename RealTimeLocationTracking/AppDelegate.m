//
//  AppDelegate.m
//  RealTimeLocationTracking
//
//  Created by Hema on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "AppDelegate.h"
#import "MMMaterialDesignSpinner.h"
#import "MyDatabase.h"

@import GoogleMaps;

@interface AppDelegate ()<CLLocationManagerDelegate>
{

    UIImageView *spinnerBackground;
    UIView *loaderView;
    CLLocationManager *locationManager;
    NSTimer *remoteTimer, *localTimer;
    bool isTracking;
    NSString *trackingLatitude, *trackingLongitude,*trackingDate;
    NSString *oldTrackingLatitude, *oldTrackingLongitude;
    NSTimer *backgroundTimerForDatabase, *backgroundTimerForService;
}
@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;
@property (nonatomic, strong) UILabel *loaderLabel;
@end

@implementation AppDelegate

#pragma mark - Global indicator view
- (void)showIndicator {
    
    spinnerBackground=[[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 50, 50)];
    spinnerBackground.backgroundColor=[UIColor whiteColor];
    spinnerBackground.layer.cornerRadius=25.0f;
    spinnerBackground.clipsToBounds=YES;
    spinnerBackground.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    loaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
    loaderView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    [loaderView addSubview:spinnerBackground];
    
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.spinnerView.tintColor = [UIColor colorWithRed:13.0/255.0 green:213.0/255.0 blue:178.0/255.0 alpha:1.0];
    self.spinnerView.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    self.spinnerView.lineWidth=3.0f;
    [self.window addSubview:loaderView];
    [self.window addSubview:self.spinnerView];
    [self.spinnerView startAnimating];
}

- (void)stopIndicator
{
    [loaderView removeFromSuperview];
    [self.spinnerView removeFromSuperview];
    [self.loaderLabel removeFromSuperview];
    [self.spinnerView stopAnimating];
}
#pragma mark - end
#pragma mark - App life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Google API key(monika@ranosys.com)
    [GMSServices provideAPIKey:googleAPIKey];
    
    oldTrackingLongitude = @"";
    oldTrackingLatitude = @"";
    
    [UserDefaultManager setValue:@"1" key:@"userId"];
    
    //check if database exists or not.
    [MyDatabase checkDataBaseExistence];

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - end

@end
