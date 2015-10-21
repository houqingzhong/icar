//
//  HttpEngine.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpEngine : NSObject


+ (void)recommend:(NSString *)strURL callback:(void (^)(NSArray *))callback;


@end
