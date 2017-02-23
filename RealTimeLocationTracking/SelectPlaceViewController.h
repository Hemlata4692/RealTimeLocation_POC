//
//  SelectPlaceViewController.h
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "DirectionPathViewController.h"
@interface SelectPlaceViewController : UIViewController
@property(strong, nonatomic) MapViewController *MapViewObj;
@property(strong, nonatomic) DirectionPathViewController *DirectionViewObj;
@property (nonatomic, strong) LocationObject *locationManager;
@property BOOL isDirectionView;

@end
