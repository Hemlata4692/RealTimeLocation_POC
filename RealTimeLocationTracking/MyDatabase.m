//
//  MyDatabase.m
//  ZebraPrinter
//
//  Created by Sumit on 17/06/14.
//  Copyright (c) 2014 Sumit. All rights reserved.
//

#import "MyDatabase.h"
static NSString *databaseName=@"LocationTracking.sqlite";
static sqlite3 *locationTrackingDatabase = nil;
@implementation MyDatabase

#pragma mark - Check Database existence
+(NSString *) getDBPath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)	;
    NSString *documentDir = [paths objectAtIndex:0];
    documentDir = [documentDir stringByAppendingPathComponent:databaseName];
    NSLog(@"documentDir path: %@",documentDir);
    return documentDir;
}

+ (void)checkDataBaseExistence
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    BOOL success=[fileManager fileExistsAtPath:[self getDBPath]];
    if(!success)
    {
        NSString *defaultDBPath=[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:databaseName];
        success=[fileManager copyItemAtPath:defaultDBPath  toPath:[self getDBPath] error:&error];
        if(!success)
        {
            NSAssert1(0,@"failed to create database with message '%@'.",[error localizedDescription]);
        }
    }
}
#pragma mark - end

#pragma mark - Insert query
+ (void)insertIntoDatabase:(const char *)query tempArray:(NSArray *)tempArray
{
    sqlite3_stmt *dataRows=nil;
    if(sqlite3_open([[self getDBPath] UTF8String],&locationTrackingDatabase) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(locationTrackingDatabase, query, -1, &dataRows, NULL)!=SQLITE_OK)
        {
            NSAssert1(0,@"error while preparing  %s",sqlite3_errmsg(locationTrackingDatabase));
        }
        for(int x=0;x<[tempArray count];x++)
        {
            if([tempArray objectAtIndex:x] == [NSNull null])
            {
                NSLog(@"entered here");
                NSMutableArray * temp =[NSMutableArray arrayWithArray:tempArray];
                [temp replaceObjectAtIndex:x withObject:@"N.A."];
                tempArray=[NSArray arrayWithArray:temp];
            }
            if([[tempArray objectAtIndex:x] isKindOfClass:[NSNumber class]])
            {
                if (x==2 || x==3)
                {
                    sqlite3_bind_double(dataRows,x+1,[[tempArray objectAtIndex:x]doubleValue]);
                }
                else
                {
                    sqlite3_bind_int(dataRows,x+1,[[tempArray objectAtIndex:x]intValue]);
                }
                
                NSLog(@"this is number %f",(float)[[tempArray objectAtIndex:x]floatValue]);
            }
            else
            {
                sqlite3_bind_text(dataRows, x+1, [[tempArray objectAtIndex:x] UTF8String],-1,SQLITE_TRANSIENT);
                NSLog(@"this is date n time  %@",[tempArray objectAtIndex:x]);

            }
        }
        if (SQLITE_DONE!=sqlite3_step(dataRows))
        {
            char *err;
            err=(char *) sqlite3_errmsg(locationTrackingDatabase);
            if (err)
                sqlite3_free(err);
            
        }
        sqlite3_finalize(dataRows);
    }
    else{
        sqlite3_close(locationTrackingDatabase);
        locationTrackingDatabase=nil;
        
    }
}

#pragma mark - end
+(bool)checkRecordDuplecasy:(NSString *)lat longitude:(NSString *)longitude
{
    NSInteger lastRowId = sqlite3_last_insert_rowid((__bridge sqlite3 *)(databaseName));
//    NSLog(@"lastRowId is %ld",(long)lastRowId);
    NSMutableArray *tmpAry=[MyDatabase getDataFromLocationTable:[[NSString stringWithFormat:@"SELECT * FROM LocationTracking WHERE ROWID = %ld",lastRowId] UTF8String]];
    NSLog(@"ary is %@",tmpAry);
    return true;
}

#pragma mark - Delete query
+ (void)deleteRecord:(const char *)query
{
    sqlite3_stmt *dataRows=nil;
    if(sqlite3_open([[self getDBPath] UTF8String],&locationTrackingDatabase) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(locationTrackingDatabase, query, -1, &dataRows, NULL)!=SQLITE_OK)
        {
            char *err;
            err=(char *) sqlite3_errmsg(locationTrackingDatabase);
            if (err)
                sqlite3_free(err);
        }
        
        if (SQLITE_DONE!=sqlite3_step(dataRows))
        {
            char *err;
            err=(char *) sqlite3_errmsg(locationTrackingDatabase);
            if (err)
                sqlite3_free(err);
        }
        sqlite3_reset(dataRows);
        sqlite3_close(locationTrackingDatabase);
        locationTrackingDatabase=nil;
    }
}
#pragma mark - end

#pragma mark - Products fetch method
+(NSMutableArray *)getDataFromLocationTable:(const char *)query
{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    if(sqlite3_open([[self getDBPath] UTF8String], &locationTrackingDatabase) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(locationTrackingDatabase, query , -1, &statement, nil)==SQLITE_OK)
        {
            while(sqlite3_step(statement)==SQLITE_ROW)
            {
                NSMutableDictionary * dataDict = [NSMutableDictionary new];
                
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,0)] forKey:@"Id"];
//
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,1)] forKey:@"userId"];
//
                             @try {
                    float lat = (float)sqlite3_column_double(statement, 2);
                    NSNumber *latitude =[NSNumber numberWithFloat:lat];
                    [dataDict setObject:latitude  forKey:@"latitude"];
                    
                    float lng = (float)sqlite3_column_double(statement, 3);
                    NSNumber *longitude =[NSNumber numberWithFloat:lng];
                    [dataDict setObject:longitude forKey:@"longitude"];
                } @catch (NSException *exception) {
//                    NSLog(@"exception is %@",exception);
                }
                
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,4)] forKey:@"address"];

                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,5)] forKey:@"destinationAddress"];
//
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,6)] forKey:@"createdAt"];
//
                [dataDict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,7)] forKey:@"updatedAt"];
//
//                [dataDict setObject:[UserDefaultManager getValue:@"TestingTrackMethod"] forKey:@"tracking_method"];
                
                [array addObject:dataDict];
            }
        }
        sqlite3_reset(statement);
        sqlite3_close(locationTrackingDatabase);
    }
//    NSLog(@"array length in DBCls is =%lu",(unsigned long)[array count]);
    return array;
}
#pragma mark - end
@end
