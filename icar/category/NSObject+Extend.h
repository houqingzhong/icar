//
//  NSObject+Extend.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@interface NSObject (Extend)

+ (BOOL)isNull:(id)object;

+(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
//圆形效果
+(void)ImageHandleWithImageView:(UIImageView*)imageView andImageName:(NSString*)imageName;

+ (NSString *)getDurationText:(CGFloat)duration;

@end
