//
//  DownloadClient.h
//  icar
//
//  Created by 调伏自己 on 15/10/19.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Public.h"

@interface DownloadClient : NSObject
@property (nonatomic, strong) void (^backgroundSessionCompletionHandler)();
@property (nonatomic, strong) void (^callback)(CGFloat progress, NSString *albumId, NSString *trackId, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

+ (DownloadClient *)sharedInstance;

- (void)startDownload;
- (void)stopDownload:(void (^)(BOOL))callback;

- (void)setCompleteHandler:(void (^)())completionHandler identifier:(NSString *)identifier;

-( void)clearOnLanch;

- (void)currentDownloadTask;

- (NSString *)getDownloadPath:(NSDictionary *)album;

- (BOOL)isFileDownloaded:(NSString *)albumId trackId:(NSString *)trackId;

- (NSURL *)getDownloadFile:(NSDictionary *)album track:(NSDictionary *)track;

- (BOOL)hasNetwork;

-(void)isDownloading:(void (^)(BOOL))callback;

@end
