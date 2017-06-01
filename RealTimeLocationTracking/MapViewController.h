//
//  MapViewController.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 20/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationObject.h"
#import "GlobalViewController.h"

@interface MapViewController : GlobalViewController

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *otherLocation;
@property (nonatomic, strong) LocationObject *locationManager;

@end
