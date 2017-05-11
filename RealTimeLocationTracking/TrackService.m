//
//  TrackService.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 19/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "TrackService.h"
#import "TrackDetailModel.h"
#import "TrackLocationDetailModel.h"
#define kUrlTrackData                       @"storetracksdata"
#define kUrlGetTrackData                    @"getstoretracks"

@implementation TrackService

#pragma mark - Singleton instance
+ (id)sharedManager {
    static TrackService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}
#pragma mark - end

#pragma mark - Track data method
- (void)storeTrackData:(NSMutableArray *)locationDetailArray success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSLog(@"userId %@",[UserDefaultManager getValue:@"userId"]);
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"serialized_data":locationDetailArray};
    NSLog(@"request tracking %@",requestDict);
    [[Webservice sharedManager] post:kUrlTrackData parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        NSLog(@"tracking response %@",responseObject);
        if([[Webservice sharedManager] isStatusOK:responseObject]) {
            success(responseObject);
        } else {
            [myDelegate stopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
    
}
#pragma mark - end

#pragma mark - Get track data method
- (void)getStoreTrackData:(NSString *)latitude longitude:(NSString *)longitude range:(NSString *)range timeStamp:(NSString *)timeStamp success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSDictionary *requestDict = @{@"range":range,@"currentLat":latitude,@"currentLong":longitude,@"timeStamp":timeStamp};
    NSLog(@"request tracking %@",requestDict);
    [[Webservice sharedManager] post:kUrlGetTrackData parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        NSLog(@"tracking response %@",responseObject);
        if([[Webservice sharedManager] isStatusOK:responseObject]) {
            id array =[responseObject objectForKey:@"tracks"];
            if (([array isKindOfClass:[NSArray class]])) {
                NSArray * trackingDataArray = [responseObject objectForKey:@"tracks"];
                NSMutableArray *dataArray = [NSMutableArray new];
                for (int i =0; i<trackingDataArray.count; i++) {
                    TrackDetailModel *trackingData = [[TrackDetailModel alloc]init];
                    trackingData.locationDetailsArray=[[NSMutableArray alloc]init];
                    NSDictionary * trackingDataDict =[trackingDataArray objectAtIndex:i];
                    trackingData.userId =[trackingDataDict objectForKey:@"user_id"];
                    NSArray *tempArray = [[NSArray alloc]init];
                    tempArray = [trackingDataDict objectForKey:@"locationDetails"];
                    for (int i =0; i<tempArray.count; i++) {
                        TrackLocationDetailModel *trackingDetailData = [[TrackLocationDetailModel alloc]init];
                        NSDictionary * trackingDetailDict =[tempArray objectAtIndex:i];
                        trackingDetailData.latitude =[[trackingDetailDict objectForKey:@"latitude"] floatValue];
                        trackingDetailData.longitude =[[trackingDetailDict objectForKey:@"longitude"] floatValue];
                        trackingDetailData.currentDateTime =[trackingDetailDict objectForKey:@"currentDateTime"];
                        trackingDetailData.calculatedDistance =[[trackingDetailDict objectForKey:@"calculatedDistance"] intValue];
                        trackingDetailData.userId = [trackingDetailDict objectForKey:@"userId"];
                        [trackingData.locationDetailsArray addObject:trackingDetailData];
                    }
                    [dataArray addObject:trackingData];
                }
                success(dataArray);
            }
        } else {
            [myDelegate stopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
    
}
#pragma mark - end
@end
