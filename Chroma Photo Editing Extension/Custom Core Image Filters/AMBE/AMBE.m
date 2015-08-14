//
//  AMBE.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/22/15.
//
//

#import "AMBE.h"
#import "AppSingleton.h"
#import "GlobalContext.h"
#import "GlobalCIImage.h"
#import <CoreImage/CoreImage.h>
#import "UIImage-vImage.h"
#import "UIImage-Utils.h"

AppSingleton *globalObjects;

@implementation AMBE

@synthesize inputImage;

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISubtractBlendMode" keysAndValues:kCIInputImageKey, [CIImage imageWithCGImage:[[UIImage imageWithCGImage:[[GlobalContext sharedSingleton].ciContext createCGImage:[GlobalCIImage sharedSingleton].ciImage fromRect:[GlobalCIImage sharedSingleton].ciImage.extent]] equalize:TRUE stretchContrast:TRUE].CGImage], kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

/*
- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    CGImageRef cgImage;
    cgImage = [[GlobalContext sharedSingleton].ciContext createCGImage:[GlobalCIImage sharedSingleton].ciImage fromRect:[[GlobalCIImage sharedSingleton].ciImage extent]];
    vImage_CGImageFormat format = {
        .bitsPerComponent = (u_int32_t)CGImageGetBitsPerComponent(cgImage),
        .bitsPerPixel = (u_int32_t)CGImageGetBitsPerPixel(cgImage),
        .colorSpace = CGImageGetColorSpace(cgImage),
        .bitmapInfo = CGImageGetAlphaInfo(cgImage) | CGImageGetBitmapInfo(cgImage),
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault
    };
    
    vImage_CGImageFormat format_cgi = {
        .bitsPerComponent = (u_int32_t)CGImageGetBitsPerComponent(cgImage),
        .bitsPerPixel = (u_int32_t)CGImageGetBitsPerPixel(cgImage),
        .colorSpace = CGImageGetColorSpace(cgImage),
        .bitmapInfo = CGImageGetAlphaInfo(cgImage) | CGImageGetBitmapInfo(cgImage),
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault
    };
    
    //vImageConverterRef converter = vImageConverter_CreateWithCGImageFormat(&format, &format_cgi, NULL, kvImageNoFlags, kvImageNoError);
    
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));

    vImage_Buffer buf;
    buf.data = (u_int32_t *)CFDataGetBytePtr(imageData);
    buf.width = CGImageGetWidth(cgImage);
    buf.height = CGImageGetHeight(cgImage);
    buf.rowBytes = CGImageGetBytesPerRow(cgImage);
    
    vImage_Error err;
    err = vImageBuffer_Init( &buf, CGImageGetHeight(cgImage), CGImageGetWidth(cgImage), (u_int32_t)CGImageGetBitsPerPixel(cgImage), kvImageNoFlags);
    if (err)
        NSLog(@"vImageBuffer_Init error: %zi", err);

    err = vImageBuffer_InitWithCGImage( &buf, &format, NULL, cgImage, kvImageNoError );
    if (err)
        NSLog(@"vImageBuffer_InitWithCGImage error: %zi", err);
    
    err = vImageEqualization_ARGB8888(&buf, &buf, kvImageNoError);
    if (err)
        NSLog(@"vImageEqualization_ARGB8888 error: %zi", err);
    
    cgImage = vImageCreateCGImageFromBuffer( &buf, &format_cgi, NULL, NULL, kvImageNoFlags, kvImageNoError);
    [GlobalCIImage sharedSingleton].ciImage = [CIImage imageWithCGImage:cgImage]; // [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CFRelease(imageData);
        
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
        CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
        [GlobalCIImage sharedSingleton].ciImage = [self.inputImage imageByCroppingToRect:cropRectLeft];
        [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", self.inputImage, @"inputRectangle", cropRect, nil].outputImage;
    
        //self.inputImage = [CIFilter filterWithName:@"CIColorClamp" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputMinComponents", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0], @"inputMaxComponents", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0], nil].outputImage;
        
        //[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputBackgroundImageKey, self.inputImage, nil].outputImage;

        return [GlobalCIImage sharedSingleton].ciImage;
}
*/

@end