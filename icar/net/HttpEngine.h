//
//  HttpEngine.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Public.h"

@interface HttpEngine : NSObject

+ (void)getDataFromServer:(NSString *)strURL key:(NSString *)key callback:(void (^)(NSArray *))callback;

@end
