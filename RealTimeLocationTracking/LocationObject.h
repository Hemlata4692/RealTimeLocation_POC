//
//  LocationObject.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 20/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;
@protocol GetAutocompleteResultDelegate <NSObject>
@optional

//Fetch autocomplete results
- (void)returnAutocompleteSearchResults:(NSDictionary *)jsonResult isSearchValue:(BOOL)isSearchValue;

//Fetch direction API result
- (void)returnDirectionResults:(NSDictionary *)jsonResult;

//Fetch address for direction path screen
- (void)showPinOnLcation:(NSDictionary *)locationData ;

//Real time tracking
- (void)fetchRealTimeLocation:(float)latitude longitude:(float)longitude;

@end

@interface LocationObject : NSObject<CLLocationManagerDelegate> {
    
    id <GetAutocompleteResultDelegate> _delegate;
    NSString *locationType;
    id json;
    BOOL isCurrentLocationUpdated;
    BOOL isBackgroundLocationStarted;
    NSString *userAddress;
    NSString *trackingLatitude, *trackingLongitude,*trackingDate;
    NSString *oldTrackingLatitude, *oldTrackingLongitude;
    int minDistforDB;
    //Current location
    BOOL isRealTimeLocationUpdated;
    int minDistforCL;
    NSString *trackingLatitudeCL, *trackingLongitudeCL;
    NSString *oldTrackingLatitudeCL, *oldTrackingLongitudeCL,*trackingDateCL;
}

//Autocomplete
- (void) fetchAutocompleteResult: (NSString *) searchKey;
@property (nonatomic,strong) id <GetAutocompleteResultDelegate>delegate;
- (void) fetchLatitudeLongitudeFromAddress: (NSString *) descriptionString;

//Direction API
@property (nonatomic, strong) GMSMarker *destinationMarker;
- (void)fetchDirectionPathResults:(CLLocationCoordinate2D)sourceLocation destinationLocation:(CLLocationCoordinate2D)destinationLocation;

//location manager
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMarker *marker;

//To fetch current location
- (void)getLocationInfo;
- (void)getAddressMethod:(CLLocationCoordinate2D )locationCoordinate isDirectionScreen:(BOOL)isDirectionScreen;

//Background location tracking
- (void)startTrack:(int)localSyncTime serverSyncTime:(int)serverSyncTime dist:(int)dist;
- (void)stopTrack;

//Real time tracking path
- (void)startRealTimeTracking:(int)syncTime dist:(int)dist;
- (void)stopRealTimeTracking;

@end
