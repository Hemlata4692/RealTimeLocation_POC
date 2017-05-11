//
//  TrackService.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 19/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackService : NSObject

//Singleton instance
+ (id)sharedManager;
//end

//Track data method
- (void)storeTrackData:(NSMutableArray *)locationDetailArray success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Get track data method
- (void)getStoreTrackData:(NSString *)latitude longitude:(NSString *)longitude range:(NSString *)range timeStamp:(NSString *)timeStamp success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

@end
