//
//  SelectPlaceViewController.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
@interface SelectPlaceViewController : UIViewController
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property(strong, nonatomic) MapViewController *locationViewObj;
@property (nonatomic, strong) LocationObject *locationManager;

@end
