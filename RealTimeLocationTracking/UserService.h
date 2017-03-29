//
//  UserService.h
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 28/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserService : NSObject

+ (id)sharedManager;
//Login screen method
- (void)userLogin:(NSString *)email password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
@end
