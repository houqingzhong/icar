//
//  FWBaseDownload.h
//  ios_sdk
//
//  Created by fwang on 15/4/22.
//  Copyright (c) 2015年 fwang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^DataWithURLFileCallback)(NSData*);
typedef void (^FWBaseDownloadCallback)(NSDictionary*);
@interface FWBaseDownload : NSObject
+(FWBaseDownload*)sharedDownload;
-(void)download:(NSDictionary*) options completed:(FWBaseDownloadCallback) callback;
@end
