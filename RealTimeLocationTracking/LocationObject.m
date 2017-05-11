//
//  LocationObject.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 20/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "LocationObject.h"
#import "MyDatabase.h"
#import "TrackService.h"
@implementation LocationObject
@synthesize locationManager;

#pragma mark - Initialization
- (id)init
{
    if (self = [super init]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _marker = [[GMSMarker alloc] init];
        _destinationMarker = [[GMSMarker alloc] init];
        isCurrentLocationUpdated = false;
    }
    return self;
}
#pragma mark - end

#pragma mark - Location update delegates
- (void)getLocationInfo {
    [locationManager startUpdatingLocation];
    // This is being called but not starting the locationManager
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!isCurrentLocationUpdated) {
        isCurrentLocationUpdated = true;
        NSLog(@"lat%f - lon%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        [_delegate fetchRealTimeLocation:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        [locationManager stopUpdatingLocation];
        [self getAddressMethod:newLocation.coordinate isDirectionScreen:NO];
    }
    if (isRealTimeLocationUpdated) {
        isRealTimeLocationUpdated = false;
        trackingLatitudeCL = [NSString stringWithFormat:@"%lf",newLocation.coordinate.latitude];
        trackingLongitudeCL = [NSString stringWithFormat:@"%lf",newLocation.coordinate.longitude];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        trackingDateCL = [dateFormatter stringFromDate:newLocation.timestamp];
        NSLog(@"current location tracking Date: %@",trackingDateCL);
    }
    if (isBackgroundLocationStarted) {
        isBackgroundLocationStarted= false;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        trackingDate = [dateFormatter stringFromDate:newLocation.timestamp];
        NSLog(@"trackingDate: %@",trackingDate);
        trackingLatitude = [NSString stringWithFormat:@"%lf",newLocation.coordinate.latitude];
        trackingLongitude = [NSString stringWithFormat:@"%lf",newLocation.coordinate.longitude];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error while getting core location : %@",[error localizedFailureReason]);
    if ([error code] == kCLErrorDenied) {
    }
    [manager stopUpdatingLocation];
    [myDelegate stopIndicator];
}
#pragma mark - end

#pragma mark - Get address from coordinates
- (void)getAddressMethod:(CLLocationCoordinate2D )locationCoordinate isDirectionScreen:(BOOL)isDirectionScreen {
    [self getAddressFromLatLong:locationCoordinate.latitude longitude:locationCoordinate.longitude];
    [self parseDic:json];
    [myDelegate stopIndicator];
    NSDictionary *locationDict = [NSDictionary new];
    locationDict = @{@"latitude":[NSString stringWithFormat:@"%lf",locationCoordinate.latitude],@"longitude": [NSString stringWithFormat:@"%lf",locationCoordinate.longitude],@"locationAddress":userAddress};
    if (isDirectionScreen) {
        [_delegate showPinOnLcation:locationDict];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newLocationAddress" object:nil userInfo:locationDict];
    }
}
- (id)getAddressFromLatLong:(float)latitude longitude:(float)longitude {
    NSString *req = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false", latitude,longitude];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    if (data != nil) {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if ([[json objectForKey:@"results"] count] == 0) {
            locationType = @"";
        }
        else{
            if ([[[[json objectForKey:@"results" ] objectAtIndex:0] objectForKey:@"types"] count]==0) {
                locationType =@"";
            }
            else {
                locationType = [[[[json objectForKey:@"results" ] objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0];
            }
        }
        return json;
    }
    else {
        return data;
    }
}

- (NSString *) parseDic: (NSDictionary*)dataDic  {
    NSString *status =[dataDic objectForKey:@"status"];
    if ([status isEqualToString:@"OK"]) {
        status = [[dataDic[@"results"] objectAtIndex:0] objectForKey:@"formatted_address"];
        userAddress = status;
    }
    else {
        userAddress = @"";
        status = @"please check your internet connection.";
    }
    return status;
}
#pragma mark - end

#pragma mark - Tracking methods
//Start location tracking
- (void)startTrack:(int)localSyncTime serverSyncTime:(int)serverSyncTime dist:(int)dist {
    minDistforDB = dist;
    //    isBackgroundLocationStarted = true;
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        locationManager.allowsBackgroundLocationUpdates = YES;
    }
    locationManager.pausesLocationUpdatesAutomatically = NO;
    // Start location updates
    isBackgroundLocationStarted= true;
    [locationManager startUpdatingLocation];
    if (![myDelegate.localTimer isValid]) {
        myDelegate.localTimer = [NSTimer scheduledTimerWithTimeInterval: localSyncTime
                                                                 target: self
                                                               selector: @selector(startTrackingForLocalDatabase)
                                                               userInfo: nil
                                                                repeats: YES];
    }
    if (![myDelegate.serverTimer isValid]) {
        myDelegate.serverTimer = [NSTimer scheduledTimerWithTimeInterval: serverSyncTime
                                                                  target: self
                                                                selector: @selector(startTrackingForServer)
                                                                userInfo: nil
                                                                 repeats: YES];
    }
}

- (int)fetchDistanceBetweenTwoLocations:(NSString *)latitude longitude:(NSString *)longitude oldLatitude:(NSString *)oldLatitude oldLongitude:(NSString *)oldLongitude {
    CLLocation *source = [[CLLocation alloc] initWithLatitude:[oldLatitude floatValue] longitude:[oldLongitude floatValue]];
    CLLocation *destination = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
    int distanceFromCurrentLocation = [source distanceFromLocation:destination];
    NSLog(@"distance %d",distanceFromCurrentLocation);
    return distanceFromCurrentLocation;
}

//Stop location tracking
- (void)stopTrack {
    // Stop location updates
    isBackgroundLocationStarted = false;
    [myDelegate.localTimer invalidate];
    myDelegate.localTimer = nil;
    [myDelegate.serverTimer invalidate];
    myDelegate.serverTimer = nil;
    trackingLatitude = @"";
    trackingLongitude = @"";
    [locationManager stopUpdatingLocation];
}

//Save data to server
- (void)startTrackingForServer {
    NSMutableArray *gpsInfo = [NSMutableArray new];
    NSString *query=[NSString stringWithFormat:@"SELECT * FROM LocationTracking limit 0,30"];
    gpsInfo =[MyDatabase getDataFromLocationTable:[query UTF8String]];
    NSLog(@"database entry code:%lu",(unsigned long)gpsInfo.count);
    if (gpsInfo.count>0) {
        NSLog(@"##############database entry code:%lu",(unsigned long)gpsInfo.count);
        
        [[TrackService sharedManager] storeTrackData:gpsInfo success:^(id responseObject)
         {
             //             [MyDatabase deleteRecord:[@"DELETE from LocationTracking limit 0,30 WHERE userId" UTF8String]];
             
             NSString *deleteSQL = [NSString stringWithFormat: @"DELETE FROM LocationTracking WHERE userId = '%@' LIMIT 30",[UserDefaultManager getValue:@"userId"]];
             [MyDatabase deleteRecord:[deleteSQL UTF8String]];
         
         } failure:^(NSError *error)
         {
             [NSTimer scheduledTimerWithTimeInterval: 30
                                              target: self
                                            selector: @selector(startTrackingForServer)
                                            userInfo: nil
                                             repeats: NO];
         }];
    }
}

//Save data in local database
- (void)startTrackingForLocalDatabase {
    isBackgroundLocationStarted = true;
    int distance = [self fetchDistanceBetweenTwoLocations:trackingLatitude longitude:trackingLongitude oldLatitude:oldTrackingLatitude oldLongitude:oldTrackingLongitude];
    if (distance >= minDistforDB) {
        oldTrackingLatitude = trackingLatitude;
        oldTrackingLongitude = trackingLongitude;
        if ((!([trackingLongitude length] == 0 || [trackingLatitude length] == 0) &&[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] != nil) && ([trackingLongitude floatValue]!=0.0 && [trackingLatitude floatValue]!=0.0)) {
            NSArray * DataBaseArray = [[NSArray alloc]initWithObjects:[UserDefaultManager getValue:@"userId"],[NSNumber numberWithDouble:[trackingLatitude doubleValue]],[NSNumber numberWithDouble:[trackingLongitude doubleValue]],trackingDate,nil];
            NSString *temp=[NSString stringWithFormat:@"INSERT INTO LocationTracking values(?,?,?,?)"];
            [MyDatabase insertIntoDatabase:[temp UTF8String] tempArray:[NSArray arrayWithArray:DataBaseArray]];
        }
        else {
            [myDelegate.localTimer invalidate];
            myDelegate.localTimer = nil;
        }
    }
    else {
        NSLog(@"set distance is minimum then travelled distance");
    }
}
#pragma mark - end

#pragma mark - Google autocomplete API
- (void) fetchAutocompleteResult: (NSString *) searchKey {
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&radius=%@&key=%@", [NSString stringWithFormat:@"%@",searchKey], [NSString stringWithFormat:@"%i",500],googleAPIKey];
    NSString* urlTextEscaped = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:urlTextEscaped];
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedAutocompleteData:) withObject:data waitUntilDone:YES];
    });
}

//fetch data from autocomplete api
- (void)fetchedAutocompleteData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization
                              JSONObjectWithData:responseData options:kNilOptions
                              error:&error];
    [_delegate returnAutocompleteSearchResults:jsonDict isSearchValue:true];
}
#pragma mark - end

#pragma mark - Fetch location coordinate from address
- (void)fetchLatitudeLongitudeFromAddress:(NSString *)addressString {
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", [NSString stringWithFormat:@"%@",addressString]];
    NSString* urlTextEscaped = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:urlTextEscaped];
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(getLatitudeLongitudeFromAddress:) withObject:data waitUntilDone:YES];
    });
}

- (void)getLatitudeLongitudeFromAddress:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization
                              JSONObjectWithData:responseData options:kNilOptions
                              error:&error];
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    [_delegate returnAutocompleteSearchResults:jsonDict isSearchValue:false];
}
#pragma mark - end

#pragma mark - Fetch direction path
- (void)fetchDirectionPathResults:(CLLocationCoordinate2D)sourceLocation destinationLocation:(CLLocationCoordinate2D)destinationLocation {
    NSString *url = [NSString stringWithFormat:
                     @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                     @"https://maps.googleapis.com/maps/api/directions/json",
                     sourceLocation.latitude,sourceLocation.longitude,
                     destinationLocation.latitude,destinationLocation.longitude,
                     googleAPIKey];
    NSString* urlTextEscaped = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:urlTextEscaped];
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedDirectionData:) withObject:data waitUntilDone:YES];
    });
    
}

- (void)fetchedDirectionData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization
                              JSONObjectWithData:responseData options:kNilOptions
                              error:&error];
    [_delegate returnDirectionResults:jsonDict];
}
#pragma mark - end

#pragma mark - Real time tracking
- (void)startRealTimeTracking:(int)syncTime dist:(int)dist {
    minDistforCL = dist;
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        locationManager.allowsBackgroundLocationUpdates = YES;
    }
    locationManager.pausesLocationUpdatesAutomatically = NO;
    // Start location updates
    isBackgroundLocationStarted= false;
    isCurrentLocationUpdated = true;
    isRealTimeLocationUpdated = true;
    NSLog(@"In real time tracking --- isRealTimeLocationUpdated = true!!!");
    [locationManager startUpdatingLocation];
    if (![myDelegate.currentLocationTrackTimer isValid]) {
        myDelegate.currentLocationTrackTimer = [NSTimer scheduledTimerWithTimeInterval: syncTime
                                                                                target: self selector: @selector(saveUsersLocationInDatabase) userInfo: nil repeats: YES];
    }
}

- (void)saveUsersLocationInDatabase {
    isRealTimeLocationUpdated = true;
    int distance = [self fetchDistanceBetweenTwoLocations:trackingLatitudeCL longitude:trackingLongitudeCL oldLatitude:oldTrackingLatitudeCL oldLongitude:oldTrackingLongitudeCL];
    if (distance >= minDistforDB) {
        oldTrackingLatitudeCL = trackingLatitudeCL;
        oldTrackingLongitudeCL = trackingLongitudeCL;
        if ((!([trackingLongitudeCL length] == 0 || [trackingLatitudeCL length] == 0) &&[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] != nil) && ([trackingLongitudeCL floatValue]!=0.0 && [trackingLatitudeCL floatValue]!=0.0)) {
            NSArray * DataBaseArray = [[NSArray alloc]initWithObjects:[UserDefaultManager getValue:@"userId"],[NSNumber numberWithDouble:[trackingLatitudeCL doubleValue]],[NSNumber numberWithDouble:[trackingLongitudeCL doubleValue]],trackingDateCL,nil];
            NSString *temp=[NSString stringWithFormat:@"INSERT INTO SelfLocationTracking values(?,?,?,?)"];
            [MyDatabase insertIntoDatabase:[temp UTF8String] tempArray:[NSArray arrayWithArray:DataBaseArray]];
        }
        else {
            [myDelegate.localTimer invalidate];
            myDelegate.localTimer = nil;
        }
    }
    else {
        NSLog(@"set distance is minimum then travelled distance");
    }
}
#pragma mark - end

#pragma mark - Stop real time tracking
- (void)stopRealTimeTracking {
    isRealTimeLocationUpdated = false;
    [myDelegate.currentLocationTrackTimer invalidate];
    myDelegate.currentLocationTrackTimer = nil;
    [locationManager stopUpdatingLocation];
}
#pragma mark - end
@end
