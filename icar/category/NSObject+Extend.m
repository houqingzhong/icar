//
//  NSObject+Extend.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "NSObject+Extend.h"

@implementation NSObject (Extend)

+ (BOOL)isNull:(id)object
{
    return (object == nil || [object isKindOfClass:[NSNull class]]);
}

+(void)ImageHandleWithImageView:(UIImageView *)imageView andImageName:(NSString *)imageName
{
    [imageView setImage:[UIImage imageNamed:imageName]];
    imageView.layer.cornerRadius=90;
    imageView.layer.borderWidth=10.0;
    imageView.layer.borderColor=[UIColor  blackColor].CGColor;
    imageView.clipsToBounds=YES;
}
+(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

+ (NSString *)getDurationText:(CGFloat)duration
{
    if (duration < 60) {
        return [NSString stringWithFormat:@"00:00:%02.0f", duration];
    }
    else if(duration/60 < 60)
    {
        CGFloat sec = (NSInteger)duration%60;
        CGFloat min = duration/60;
        return [NSString stringWithFormat:@"00:%02.0f:%02.0f", min, sec];
    }
    else if(duration/3600 > 0)
    {
        CGFloat hour = (NSInteger)duration/3600;
        
        duration = (NSInteger)duration%3600;
        
        if(duration/60 < 60)
        {
            CGFloat sec = (NSInteger)duration%60;
            CGFloat min = duration/60;
            return [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hour, min, sec];
        }
        
    }

    return @"00:00:00";
}

@end
