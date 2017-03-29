//
//  AppDelegate.h
//  RealTimeLocationTracking
//
//  Created by Hema on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//Indicator method
- (void)showIndicator;
- (void)stopIndicator;
//Timer for local database
@property (strong, nonatomic) NSTimer *localTimer;
//Timer for Real time tracking
@property (strong, nonatomic) NSTimer *currentLocationTrackTimer;

@end

