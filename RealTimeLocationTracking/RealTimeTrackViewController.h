//
//  RealTimeTrackViewController.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 03/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RealTimeTrackViewController : GlobalViewController

@property (nonatomic, strong) LocationObject *locationManager;
@property (nonatomic) long  selectedMenu;
@end
