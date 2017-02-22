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
@protocol getAutocompleteResultDelegate <NSObject>
@optional
-(void)returnAutocompleteSearchResults:(NSDictionary *)jsonResult isSearchValue:(BOOL)isSearchValue;
@end

@interface LocationObject : NSObject<CLLocationManagerDelegate> {
    
    id <getAutocompleteResultDelegate> _delegate;
    NSString *locationType;
    id json;
    BOOL isCurrentLocationUpdated;
    BOOL isBackgroundLocationStarted;
    NSString *userAddress;
    NSTimer *localTimer;
    NSString *trackingLatitude, *trackingLongitude,*trackingDate;
}
//Autocomplete
-(void) fetchAutocompleteResult: (NSString *) searchKey;
@property (nonatomic,strong) id <getAutocompleteResultDelegate>delegate;
-(void) fetchLatitudeLongitudeFromAddress: (NSString *) descriptionString;

//location manager
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMarker *marker;

//To fetch current location
- (void)getLocationInfo;
-(void)getAddressMethod:(CLLocationCoordinate2D )locationCoordinate;

//Background location tracking
- (void)startTrack;
- (void)stopTrack;


@end
