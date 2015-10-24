//
//  PublicMethod.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "PublicMethod.h"
#import "Public.h"
#import <sys/xattr.h>

NSString *FormattedTimeStringFromTimeInterval(NSTimeInterval timeInterval) {
    
    NSString *timeString = nil;
    const int secsPerMin = 60;
    const int minsPerHour = 60;
    const char *timeSep = ":";
    NSTimeInterval seconds = timeInterval;
    seconds = floor(seconds);
    
    if(seconds < 60.0) {
        timeString = [NSString stringWithFormat:@"0:%02.0f", seconds];
    }
    else {
        int mins = seconds/secsPerMin;
        int secs = seconds - mins*secsPerMin;
        
        if(mins < 60.0) {
            timeString = [NSString stringWithFormat:@"%d%s%02d", mins, timeSep, secs];
        }
        else {
            int hours = mins/minsPerHour;
            mins -= hours * minsPerHour;
            timeString = [NSString stringWithFormat:@"%d%s%02d%s%02d", hours, timeSep, mins, timeSep, secs];
        }
    }
    return timeString;
}

@implementation PublicMethod

+ (void)saveDataToLocal:(id)obj key:(NSString *)key
{
    if (obj && key) {
        //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        //[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        App(app);
        [app.localStore putObject:obj withId:key intoTable:server_data_cahce];
    }

}

+ (id)getLocalData:(NSString *)key
{
    if (key) {
        App(app);
        id obj = [app.localStore getObjectById:key fromTable:server_data_cahce];

        //id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        return obj;//[NSKeyedUnarchiver unarchiveObjectWithData:obj];
    }

    return nil;
}

+ (void)saveHistory:(NSDictionary *)album track:(NSDictionary *)track callback:(void (^)(void))callback
{
    if (album && track) {

        App(app);
        
        NSString *sql = [NSString stringWithFormat:@"select * from history where album_id = %@ and  track_id = %@", album[@"id"], track[@"id"]];
        [app.queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:sql];

            if([rs next])
            {
                [db executeUpdate:@"update history set timestamp = ? where album_id = ? and track_id = ?",  @([PublicMethod getTimeNow]), album[@"id"], track[@"id"]];

            }
            //向数据库中插入一条数据
            else
            {
                [db executeUpdate:@"INSERT INTO history (album_id, track_id, album_info, track_info, timestamp) VALUES (?, ?, ?, ?, ?)", album[@"id"], track[@"id"], [album JSONString], [track JSONString],  @([PublicMethod getTimeNow])];
            }
            
            [rs close];



        }];
        
    }
}

+ (void)updateHistory:(NSString *)albumId trackId:(NSString *)trackId time:(NSTimeInterval)time callback:(void (^)(void))callback
{
    if (albumId.integerValue > 0 && trackId.integerValue > 0 && time >= 0) {
        
        App(app);
        
        NSString *sql = [NSString stringWithFormat:@"select * from history where album_id = %@ and  track_id = %@", albumId, trackId];
        
        [app.queue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *rs = [db executeQuery:sql];
            
            if([rs next])
            {
                
                [db executeUpdate:@"update history set time = ?, timestamp = ? where album_id = ? and track_id = ?", @(time),  @([PublicMethod getTimeNow]), albumId, trackId];
            }
            
            [rs close];

            
            if (callback) {
                callback();
            }
            
        }];
    }
}

+ (void)updateDownloadState:(NSString *)albumId trackId:(NSString *)trackId progress:(CGFloat)progress state:(DownloadState)state callback:(void (^)(void))callback
{
    if (albumId.integerValue > 0 && trackId.integerValue > 0 && progress >= 0) {
        
        App(app);
        
        NSString *sql = [NSString stringWithFormat:@"select * from download where album_id = %@ and  track_id = %@", albumId, trackId];
        
        [app.queue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *rs = [db executeQuery:sql];
            
            if([rs next])
            {
                
                [db executeUpdate:@"update download set progress = ?, timestamp = ?, download_state = ? where track_id = ? and album_id = ?", @(progress), @([PublicMethod getTimeNow]),  @(state), trackId, albumId];

            }
            
            [rs close];

            if (callback) {
                callback();
            }

        }];
    }
}

+ (void)saveDownload:(NSDictionary *)album track:(NSDictionary *)track progress:(CGFloat)progress state:(DownloadState)state
{
    if (album && track && progress >= 0) {
        
        App(app);
        
        
        [app.queue inDatabase:^(FMDatabase *db) {

            FMResultSet *rs = [db executeQuery:@"select * from download where album_id = ? and  track_id = ?", album[@"id"], track[@"id"]];
            
            if([rs next])
            {
                [db executeUpdate:@"update download set progress = ?, album_info = ?, track_info = ?, timestamp = ?, download_state = ? where track_id = ? and album_id = ?", @(progress),[album JSONString], [track JSONString],  @([PublicMethod getTimeNow]),  @(state),  track[@"id"], album[@"id"]];

            }
            //向数据库中插入一条数据
            else
            {
                [db executeUpdate:@"INSERT INTO download (album_id, track_id, album_info, track_info, progress, download_state, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?)", album[@"id"], track[@"id"], [album JSONString], [track JSONString],  @(progress), @(state),  @([PublicMethod getTimeNow])];

            }
            
            [rs close];


        }];
    }
}

+ (void)deleteDownloadAlbum:(NSString *)albumId callback:(void (^)(BOOL))callback
{
    App(app);
    
    
    [app.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"delete from download where album_id = ?", albumId];
        
        if([rs next])
        {
            
        }
        
        [rs close];
        
        if (callback) {
            callback(YES);
        }
        
    }];
}

+ (void)deleteDownloadTrack:(NSString *)trackId callback:(void (^)(BOOL))callback
{
    App(app);
    
    
    [app.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"delete from download where  track_id = ?", trackId];
        
        if([rs next])
        {
            
        }
        
        [rs close];
        
        if (callback) {
            callback(YES);
        }
        
    }];

}
+ (void)getDownloadTracks:(NSString *)albumId callback:(void (^)(NSArray*))callback
{
    App(app);

    NSString *sql = [NSString stringWithFormat:@"select * from download where album_id = %@ order by timestamp DESC", albumId];
    
    [app.queue inDatabase:^(FMDatabase *db) {

        FMResultSet *rs = [db executeQuery:sql];
        
        NSMutableArray *arr = [NSMutableArray new];
        while ([rs next]) {
            if ([rs doubleForColumn:@"download_state"] > 0) {
                NSDictionary *track = [[rs stringForColumn:@"track_info"] objectFromJSONString];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:track];
                dict[@"progress"] = @([rs doubleForColumn:@"progress"]);
                dict[@"download_state"] = @([rs doubleForColumn:@"download_state"]);
                
                [arr addObject:dict];
            }
        }
        [rs close];


        if (callback) {
            callback(arr);
        }

    }];
    
}

+ (void)getDownloadTracks:(NSString *)albumId trackId:(NSString *)trackId  callback:(void (^)(NSDictionary*))callback
{
    App(app);
    
    NSString *sql = [NSString stringWithFormat:@"select * from download where album_id = %@ order by timestamp DESC", albumId];
    
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        while ([rs next]) {
            
            if ([rs doubleForColumn:@"download_state"] > 0) {
                NSDictionary *album = [[rs stringForColumn:@"album_info"] objectFromJSONString];
                NSDictionary *track = [[rs stringForColumn:@"track_info"] objectFromJSONString];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:track];
                dict[@"progress"] = @([rs doubleForColumn:@"progress"]);
                dict[@"download_state"] = @([rs doubleForColumn:@"download_state"]);
                
                newDic[@"album"] = album;
                newDic[@"track"] = dict;
            }
        }
        
        [rs close];

        if (callback) {
            callback(newDic);
        }
        
    }];
}

+ (void)getDownloadTracks:(void (^)(NSArray*))callback
{
    App(app);
    
    NSString *sql = [NSString stringWithFormat:@"select * from download order by timestamp DESC"];
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *arr = [NSMutableArray new];
        while ([rs next]) {
            if ([rs doubleForColumn:@"download_state"] > 0) {
                NSDictionary *album = [[rs stringForColumn:@"album_info"] objectFromJSONString];
                NSDictionary *track = [[rs stringForColumn:@"track_info"] objectFromJSONString];
                NSMutableDictionary *newDic = [NSMutableDictionary new];
                newDic[@"album"] = album;
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:track];
                dict[@"progress"] = @([rs doubleForColumn:@"progress"]);
                dict[@"download_state"] = @([rs doubleForColumn:@"download_state"]);
                
                newDic[@"track"] = dict;
                [arr addObject:newDic];
            }
        }
        
        [rs close];

        
        if (callback) {
            callback(arr);
        }

    }];
}

+ (void)getDownloadTask:(void (^)(NSDictionary*))callback;
{
    App(app);
    
    NSString *sql = [NSString stringWithFormat:@"select * from download where download_state != %lu order by timestamp DESC limit 1", (unsigned long)DownloadStateDownloadFinish];
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableDictionary *newDic = nil;
        while ([rs next]) {
            if ([rs doubleForColumn:@"download_state"] > 0) {
                newDic = [NSMutableDictionary new];
                NSDictionary *album = [[rs stringForColumn:@"album_info"] objectFromJSONString];
                NSDictionary *track = [[rs stringForColumn:@"track_info"] objectFromJSONString];
                newDic[@"album"] = album;
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:track];
                dict[@"progress"] = @([rs doubleForColumn:@"progress"]);
                dict[@"download_state"] = @([rs doubleForColumn:@"download_state"]);
                
                newDic[@"track"] = dict;
            }
        }
        [rs close];

        if (callback) {
            callback(newDic);
        }

    }];
}

+ (void)getDownloadTask:(NSString *)trackId callback:(void (^)(NSDictionary*))callback;
{
    App(app);
    
    NSString *sql = [NSString stringWithFormat:@"select * from download where track_id = %@ limit 1", trackId];
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        
        NSMutableDictionary *dict = nil;
        while ([rs next]) {
            NSDictionary* track = [[rs stringForColumn:@"track_info"] objectFromJSONString];
            dict = [NSMutableDictionary dictionaryWithDictionary:track];
            dict[@"time"] = @([rs doubleForColumn:@"time"]);
        }
        
        [rs close];
        
        
        if (callback) {
            callback(dict);
        }
    }];
    
}

+ (void)deleteHistory:(NSString *)trackId callback:(void (^)(BOOL))callback
{
    App(app);
    
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"delete from history where track_id = ?", trackId];
        
        while ([rs next]) {
            NSLog(@"%@", rs);
        }
        
        [rs close];
        
        
        if (callback) {
            callback(YES);
        }
    }];

}

+ (void)deleteHistoryAlbum:(NSString *)albumId callback:(void (^)(BOOL))callback
{
    App(app);
    
    [app.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"delete from history where album_id = ?", albumId];

        while ([rs next]) {
            NSLog(@"%@", rs);
        }
        
        [rs close];
        
        
        if (callback) {
            callback(YES);
        }
    }];
    
}

+ (void)getHistoryTrack:(NSString *)trackId callback:(void (^)(NSDictionary*))callback;
{
    App(app);
    
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select * from history where track_id = ? limit 1", trackId];
        
        NSMutableDictionary *dict = nil;
        while ([rs next]) {
            NSDictionary* track = [[rs stringForColumn:@"track_info"] objectFromJSONString];
            dict = [NSMutableDictionary dictionaryWithDictionary:track];
            dict[@"time"] = @([rs doubleForColumn:@"time"]);
        }
        
        [rs close];

        
        if (callback) {
            callback(dict);
        }
    }];

}


//+ (void)getLastPlay:(void (^)(NSDictionary*))callback;
//{
//    App(app);
//    
//    NSString *sql = [NSString stringWithFormat:@"select * from history order by timestamp limit 1"];
//    [app.queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:sql];
//        
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        while ([rs next]) {
//            NSDictionary* track = [[rs stringForColumn:@"track_info"] objectFromJSONString];
//            NSDictionary* album = [[rs stringForColumn:@"album_info"] objectFromJSONString];
//            NSMutableDictionary *newTrack = [NSMutableDictionary dictionaryWithDictionary:track];
//            dict[@"time"] = @([rs doubleForColumn:@"time"]);
//            
//            dict[@"album"] = album;
//            dict[@"track"] = newTrack;
//        }
//        
//        
//        [rs close];
//        
//        
//        if (callback) {
//            callback(dict);
//        }
//    }];
//}


+ (UInt64)getTimeNow
{

    UInt64 time = [[NSDate date] timeIntervalSince1970]*1000;

    return time;
}

+ (NSString*)dataToJsonString:(id)object
{
    
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


+ (void)allowGprsDownload:(BOOL)flag
{
//    [[NSUserDefaults standardUserDefaults] setObject:@(flag) forKey:];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    App(app);
    [app.localStore putObject:@{allow_3g_download:@(flag)} withId:allow_3g_download intoTable:setting_data_cache];

}

+ (void)allowGprsPlay:(BOOL)flag
{
//    [[NSUserDefaults standardUserDefaults] setObject:@(flag) forKey:@"allow_3g_play"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    App(app);
    [app.localStore putObject:@{allow_3g_play:@(flag)} withId:allow_3g_play intoTable:setting_data_cache];
}

+ (BOOL)isAllowPlayInGprs
{
    
    App(app);
    NSDictionary *dict = [app.localStore getObjectById:allow_3g_play fromTable:setting_data_cache];
    BOOL allow = [dict[allow_3g_play] boolValue];
    //BOOL allow = [[NSUserDefaults standardUserDefaults] boolForKey:@"allow_3g_play"];
    
    return allow;
}

+ (BOOL)isAllowDownloadInGprs
{
    App(app);
    //BOOL allow = [[app.localStore getObjectById:allow_3g_download fromTable:setting_data_cache] boolValue];
    //return [[NSUserDefaults standardUserDefaults] boolForKey:@"allow_3g_download"];
    NSDictionary *dict = [app.localStore getObjectById:allow_3g_download fromTable:setting_data_cache];
    BOOL allow = [dict[allow_3g_download] boolValue];
    
    return allow;
}

//http://developer.apple.com/library/ios/#qa/qa1719/_index.html
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = FALSE;
    if (&NSURLIsExcludedFromBackupKey > 0) {
        success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                 forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
    }else{
        assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
        
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        success = (result == 0);
    }
    return success;
}

+ (NSString *)getDownloadPath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [array lastObject];
    
    docDir = [docDir stringByAppendingPathComponent:@"mp3"];
    
    return docDir;
}

+ (NSString *)getDocumentPath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [array lastObject];
    
    return docDir;
}
@end
