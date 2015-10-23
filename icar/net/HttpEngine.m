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


+ (void)getDataFromServer:(NSString *)strURL key:(NSString *)key callback:(void (^)(NSArray *))callback
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = nil;

    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"code"] integerValue] == 0) {
            
            [PublicMethod saveDataToLocal:dict[@"data"] key:key];
            
            callback(dict[@"data"]);
        }
        else
        {
            NSArray *localData = (NSArray *)[PublicMethod getLocalData:key];
            if (callback) {
                callback(localData);
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSArray *localData = (NSArray *)[PublicMethod getLocalData:key];
        if (callback) {
            callback(localData);
        }
    }];
}

@end
