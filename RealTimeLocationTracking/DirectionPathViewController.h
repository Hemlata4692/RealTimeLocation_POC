//
//  DirectionPathViewController.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 22/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectionPathViewController : UIViewController
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *autoCompleteLocation;
@property (nonatomic, strong) LocationObject *locationManager;

@end
