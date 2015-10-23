//
//  HttpEngine.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "HttpEngine.h"
#import <AFNetworking.h>
#import "Public.h"

@interface HttpEngine()
{
    
}
@end

@implementation HttpEngine


+ (void)getDataFromServer:(NSString *)strURL type:(ServerDataRequestType)type callback:(void (^)(NSArray *))callback;
{
    if(![[DownloadClient sharedInstance] hasNetwork])
    {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:NetworkError
                                        type:TSMessageNotificationTypeMessage];

        NSArray *localData = (NSArray *)[PublicMethod getLocalData:[PublicMethod getDataKey:type]];
        if (callback) {
            callback(localData);
        }
        return;
    }

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = nil;

    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"code"] integerValue] == 0) {
            
            [PublicMethod saveDataToLocal:dict[@"data"] key:[PublicMethod getDataKey:type]];
            
            callback(dict[@"data"]);
        }
        else
        {
            NSArray *localData = (NSArray *)[PublicMethod getLocalData:[PublicMethod getDataKey:type]];
            if (callback) {
                callback(localData);
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSArray *localData = (NSArray *)[PublicMethod getLocalData:[PublicMethod getDataKey:type]];
        if (callback) {
            callback(localData);
        }
    }];
}

@end
