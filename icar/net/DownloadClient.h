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
@property (nonatomic, strong) void (^callback)(CGFloat progress, NSString *albumId, NSString *trackId);

+ (DownloadClient *)sharedInstance;

- (void)startDownload;

- (void)setCompleteHandler:(void (^)())completionHandler identifier:(NSString *)identifier;

-( void)clearOnLanch;

- (void)currentDownloadTask;

- (NSString *)getDownloadPath:(NSDictionary *)album;

- (BOOL)isFileDownloaded:(NSString *)albumId trackId:(NSString *)trackId;

@end
