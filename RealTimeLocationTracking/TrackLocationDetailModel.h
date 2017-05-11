//
//  TrackLocationDetailModel.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 09/05/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackLocationDetailModel : NSObject

@property(nonatomic,retain)NSString * currentDateTime;
@property(nonatomic,retain)NSString * userId;
@property(nonatomic)float latitude;
@property(nonatomic)float longitude;
@property(nonatomic)int calculatedDistance;

@end
