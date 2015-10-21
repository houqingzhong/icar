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

+ (void)recommend:(NSString *)strURL callback:(void (^)(NSArray *))callback
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = nil;

    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"code"] integerValue] == 0) {
            callback(dict[@"data"]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil);
    }];
}

@end
