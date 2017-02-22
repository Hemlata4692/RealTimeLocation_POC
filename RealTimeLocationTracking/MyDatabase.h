//
//  MyDatabase.h
//  ZebraPrinter
//
//  Created by Sumit on 17/06/14.
//  Copyright (c) 2014 Sumit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface MyDatabase : NSObject
+(NSString *) getDBPath;
+ (void) checkDataBaseExistence;
+(bool)checkRecordDuplecasy:(NSString *)lat longitude:(NSString *)longitude;
+ (void)insertIntoDatabase:(const char *)query tempArray:(NSArray *)tempArray;
+(NSMutableArray *)getDataFromLocationTable:(const char *)query;
+ (void)deleteRecord:(const char *)query;
@end
