//
//  UserService.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 28/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "UserService.h"
#define kUrlLogin                       @"login"

@implementation UserService

#pragma mark - Singleton instance
+ (id)sharedManager {
    static UserService *sharedMyManager = nil;
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

#pragma mark- Login
//Login
- (void)userLogin:(NSString *)email password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSDictionary *requestDict = @{@"email":email,@"password":password};
    NSLog(@"request login %@",requestDict);
    [[Webservice sharedManager] post:kUrlLogin parameters:requestDict success:^(id responseObject) {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         NSLog(@"login response %@",responseObject);
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
#pragma mark- end

@end
