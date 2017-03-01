//
//  LocationObject.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 20/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "LocationObject.h"
#import "MyDatabase.h"
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

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation {
    
    if (!isCurrentLocationUpdated) {
        isCurrentLocationUpdated = true;
        NSLog(@"lat%f - lon%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        [locationManager stopUpdatingLocation];
        [self getAddressMethod:newLocation.coordinate isDirectionScreen:NO];
       
        
        if (isBackgroundLocationStarted) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:locale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            trackingDate = [dateFormatter stringFromDate:newLocation.timestamp];
            trackingLatitude = [NSString stringWithFormat:@"%lf",newLocation.coordinate.latitude];
            trackingLongitude = [NSString stringWithFormat:@"%lf",newLocation.coordinate.longitude];
        }

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
-(void)getAddressMethod:(CLLocationCoordinate2D )locationCoordinate isDirectionScreen:(BOOL)isDirectionScreen{
    [self getAddressFromLatLong:locationCoordinate.latitude longitude:locationCoordinate.longitude];
    [self parseDic:json];
    
    trackingLatitude = [NSString stringWithFormat:@"%lf",locationCoordinate.latitude];
    trackingLongitude = [NSString stringWithFormat:@"%lf",locationCoordinate.longitude];
    [myDelegate stopIndicator];
    
    NSDictionary *locationDict = [NSDictionary new];
    locationDict = @{@"latitude":trackingLatitude,@"longitude": trackingLongitude,@"locationAddress":userAddress};
    
    if (isDirectionScreen) {
        [_delegate showPinOnLcation:locationDict];
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newLocationAddress" object:nil userInfo:locationDict];
    }
}
-(id) getAddressFromLatLong:(float)latitude longitude:(float)longitude {
    
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
            else{
                locationType = [[[[json objectForKey:@"results" ] objectAtIndex:0] objectForKey:@"types"] objectAtIndex:0];
            }
            
        }
        return json;
    }
    else {
        return data;
    }
}
-(NSString *) parseDic: (NSDictionary*)dataDic  {
    
    NSString *status =[dataDic objectForKey:@"status"];
    if ([status isEqualToString:@"OK"]) {
        status = [[dataDic[@"results"] objectAtIndex:0] objectForKey:@"formatted_address"];
        userAddress = status;
    }
    else{
        userAddress = @"";
        status = @"please check your internet connection.";
    }
    return status;
}
#pragma mark - end

#pragma mark - Tracking methods
//Start location tracking
- (void)startTrack:(int)syncTime dist:(int)dist {
    
    minDist = dist;
    isBackgroundLocationStarted = true;
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        locationManager.allowsBackgroundLocationUpdates = YES;
    }
    locationManager.pausesLocationUpdatesAutomatically = NO;
    // Start location updates
    isCurrentLocationUpdated= false;
    [locationManager startUpdatingLocation];
    if (![localTimer isValid]) {
        
        localTimer = [NSTimer scheduledTimerWithTimeInterval: syncTime
                                                      target: self
                                                    selector: @selector(startTrackingForLocalDatabase)
                                                    userInfo: nil
                                                     repeats: YES];
        
         }
}
-(int)fetchDistanceBetweenTwoLocations {

    CLLocation *source = [[CLLocation alloc] initWithLatitude:[oldTrackingLatitude floatValue] longitude:[oldTrackingLongitude floatValue]];
    CLLocation *destination = [[CLLocation alloc] initWithLatitude:[trackingLatitude floatValue] longitude:[trackingLongitude floatValue]];
    
     int distanceFromCurrentLocation = [source distanceFromLocation:destination];
    
    NSLog(@"distance %d",distanceFromCurrentLocation);
    return distanceFromCurrentLocation;
}
//Sop location tracking
- (void)stopTrack {
    // Stop location updates
    isBackgroundLocationStarted = false;
    [localTimer invalidate];
    localTimer = nil;
    trackingLatitude = @"";
    trackingLongitude = @"";
    [locationManager stopUpdatingLocation];
}
//Save data in local database
- (void)startTrackingForLocalDatabase
{
    int distance = [self fetchDistanceBetweenTwoLocations];
    if (distance >= minDist) {
        
        oldTrackingLatitude = trackingLatitude;
        oldTrackingLongitude = trackingLongitude;
        
        if ((!([trackingLongitude length] == 0 || [trackingLatitude length] == 0) &&[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] != nil) && ([trackingLongitude floatValue]!=0.0 && [trackingLatitude floatValue]!=0.0)) {
            
            NSArray * DataBaseArray = [[NSArray alloc]initWithObjects:@"1",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],[NSNumber numberWithDouble:[trackingLatitude doubleValue]],[NSNumber numberWithDouble:[trackingLongitude doubleValue]],@"",@"",trackingDate,trackingDate,nil];
            
            NSString *temp=[NSString stringWithFormat:@"INSERT INTO LocationTracking values(?,?,?,?,?,?,?,?)"];
            [MyDatabase insertIntoDatabase:[temp UTF8String] tempArray:[NSArray arrayWithArray:DataBaseArray]];
            
        }
        else
        {
        }

    }
    else {
        NSLog(@"set distance is minimum then travelled distance");
    }

 }
#pragma mark - end

#pragma mark - Google autocomplete API
-(void) fetchAutocompleteResult: (NSString *) searchKey {
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
-(void)fetchLatitudeLongitudeFromAddress:(NSString *)addressString {
    
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
-(void)fetchDirectionPathResults:(CLLocationCoordinate2D)sourceLocation destinationLocation:(CLLocationCoordinate2D)destinationLocation {
    
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

@end
