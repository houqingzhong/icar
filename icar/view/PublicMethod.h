//
//  PublicMethod.h
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Public.h"


NSString *FormattedTimeStringFromTimeInterval(NSTimeInterval timeInterval);

@interface PublicMethod : NSObject

+ (id)getLocalData:(NSString *)key;
+ (void)saveDataToLocal:(id)obj key:(NSString *)key;

+ (void)saveHistory:(NSDictionary *)album track:(NSDictionary *)track callback:(void (^)(void))callback;

+ (void)updateHistory:(NSString *)albumId trackId:(NSString *)trackId time:(NSTimeInterval)time callback:(void (^)(void))callback;

+ (void)getDownloadTracks:(NSString *)albumId callback:(void (^)(NSArray*))callback;

+ (void)getDownloadTracks:(NSString *)albumId trackId:(NSString *)trackId  callback:(void (^)(NSDictionary*))callback;

+ (void)getDownloadTracks:(void (^)(NSArray*))callback;
+ (void)getDownloadTracksByIds:(NSArray *)trackIds callback:(void (^)(NSArray*))callback;

+ (void)getDownloadTask:(void (^)(NSDictionary*))callback;

+ (void)getDownloadTask:(NSString *)trackId callback:(void (^)(NSDictionary*))callback;

+ (void)saveDownload:(NSDictionary *)album track:(NSDictionary *)track progress:(CGFloat)progress state:(DownloadState)state;

+ (void)deleteDownloadAlbum:(NSString *)albumId callback:(void (^)(BOOL))callback;
+ (void)deleteDownloadTrack:(NSString *)trackId callback:(void (^)(BOOL))callback;

+ (void)updateDownloadState:(NSString *)albumId trackId:(NSString *)trackId progress:(CGFloat)progress state:(DownloadState)state callback:(void (^)(void))callback;

+ (void)getHistoryTrack:(NSString *)trackId callback:(void (^)(NSDictionary*))callback;

+ (void)deleteHistory:(NSString *)trackId callback:(void (^)(BOOL))callback;
+ (void)deleteHistoryAlbum:(NSString *)albumId callback:(void (^)(BOOL))callback;


+ (void)allowGprsDownload:(BOOL)flag;

+ (void)allowGprsPlay:(BOOL)flag;

+ (BOOL)isAllowDownloadInGprs;

+ (BOOL)isAllowPlayInGprs;

/**
 * 防止itunes 和 icloud自动备份特定的文件，譬如下载下来的视频等
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (NSString *)getDownloadPath;

+ (NSString *)getDocumentPath;

+ (NSIndexPath *)getNextPlayIndexPath:(PlayModeType)playMode currentIndexPath:(NSIndexPath *)currentIndexPath dataArray:(NSArray *)dataArray;
@end
