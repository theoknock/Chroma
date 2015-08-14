//
//  StretchContrastAverage.m
//  Chroma
//
//  Created by James Alan Bush on 7/17/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import "StretchContrastAverage.h"
#import "GlobalCIImage.h"
#import "GlobalContext.h"

@implementation StretchContrastAverage

@synthesize inputImage;

- (CIKernel *)stretchContrastAverageKernel
{
    static CIKernel *kernelStretchContrastAverage = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"StretchContrastAverage")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"StretchContrastAverageKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelStretchContrastAverage = [CIKernel kernelWithString:code];
    });
    
    return kernelStretchContrastAverage;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    // Image minimum
    CGRect inputExtentMin = [[GlobalCIImage sharedSingleton].ciImage extent];
    CIVector *extentMin = [CIVector vectorWithX:inputExtentMin.origin.x
                                           Y:inputExtentMin.origin.y
                                           Z:inputExtentMin.size.width
                                           W:inputExtentMin.size.height];
    CIImage *inputMinimum = [CIFilter filterWithName:@"CIAreaMinimum" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputExtentKey, extentMin, nil].outputImage;
    
    int widthMin = inputMinimum.extent.size.width;
    int heightMin = inputMinimum.extent.size.height;
    CGColorSpaceRef colorSpaceMin = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextMin = CGBitmapContextCreate(NULL, widthMin, heightMin, 8, widthMin * 4, colorSpaceMin, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpaceMin);
    
    CGContextDrawImage(contextMin, CGRectMake(0, 0, widthMin, heightMin), [[GlobalContext sharedSingleton].ciContext createCGImage:inputMinimum fromRect:CGRectMake(0, 0, widthMin, heightMin)]);
    
    unsigned int *colorDataMin = CGBitmapContextGetData(contextMin);
    unsigned int colorMin = *colorDataMin;
    
    short rMin = (colorMin >> 8) & 0xFF;
    short gMin = (colorMin >> 16) & 0xFF;
    short bMin = (colorMin >> 24) & 0xFF;
    
    float inputMinRed = [NSNumber numberWithShort:rMin].floatValue / 255.0;
    float inputMinGreen = [NSNumber numberWithShort:gMin].floatValue / 255.0;
    float inputMinBlue = [NSNumber numberWithShort:bMin].floatValue / 255.0;
    
    NSLog(@"inputMinRed: %f  inputMinGreen: %f  inputMinBlue: %f", inputMinRed, inputMinGreen, inputMinBlue);
    
    CGContextRelease(contextMin);
    
    // Image maximum
    CGRect inputExtentMax = [[GlobalCIImage sharedSingleton].ciImage extent];
    CIVector *extentMax = [CIVector vectorWithX:inputExtentMax.origin.x
                                              Y:inputExtentMax.origin.y
                                              Z:inputExtentMax.size.width
                                              W:inputExtentMax.size.height];
    CIImage *inputMaximum = [CIFilter filterWithName:@"CIAreaMaximum" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputExtentKey, extentMax, nil].outputImage;
    
    int widthMax = inputMaximum.extent.size.width;
    int heightMax = inputMaximum.extent.size.height;
    CGColorSpaceRef colorSpaceMax = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextMax = CGBitmapContextCreate(NULL, widthMax, heightMax, 8, widthMax * 4, colorSpaceMax, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpaceMax);
    
    CGContextDrawImage(contextMax, CGRectMake(0, 0, widthMax, heightMax), [[GlobalContext sharedSingleton].ciContext createCGImage:inputMaximum fromRect:CGRectMake(0, 0, widthMax, heightMax)]);
    
    unsigned int *colorDataMax = CGBitmapContextGetData(contextMax);
    unsigned int colorMax = *colorDataMax;
    
    short rMax = (colorMax >> 8) & 0xFF;
    short gMax = (colorMax >> 16) & 0xFF;
    short bMax = (colorMax >> 24) & 0xFF;
    
    float inputMaxRed = [NSNumber numberWithShort:rMax].floatValue / 255.0;
    float inputMaxGreen = [NSNumber numberWithShort:gMax].floatValue / 255.0;
    float inputMaxBlue = [NSNumber numberWithShort:bMax].floatValue / 255.0;
    
    NSLog(@"inputMaxRed: %f  inputMaxGreen: %f  inputMaxBlue: %f", inputMaxRed, inputMaxGreen, inputMaxBlue);
    
    CGContextRelease(contextMax);
    
    CGRect inputExtent = [[GlobalCIImage sharedSingleton].ciImage extent];
    CIVector *extent = [CIVector vectorWithX:inputExtent.origin.x
                                           Y:inputExtent.origin.y
                                           Z:inputExtent.size.width
                                           W:inputExtent.size.height];
    CIImage *inputAverage = [CIFilter filterWithName:@"CIAreaAverage" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputExtentKey, extent, nil].outputImage;
   
    int width = inputAverage.extent.size.width;
    int height = inputAverage.extent.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [[GlobalContext sharedSingleton].ciContext createCGImage:inputAverage fromRect:CGRectMake(0, 0, width, height)]);
    
    unsigned int *colorData = CGBitmapContextGetData(context);
    unsigned int color = *colorData;
    
    short r = (color >> 8) & 0xFF;
    short g = (color >> 16) & 0xFF;
    short b = (color >> 24) & 0xFF;
    
    float inputAvgRed = [NSNumber numberWithShort:r].floatValue / 255.0;
    float inputAvgGreen = [NSNumber numberWithShort:g].floatValue / 255.0;
    float inputAvgBlue = [NSNumber numberWithShort:b].floatValue / 255.0;
    
    CGContextRelease(context);
    
    NSLog(@"inputAvgRed: %f  inputAvgGreen: %f  inputAvgBlue: %f", inputAvgRed, inputAvgGreen, inputAvgBlue);
    
    return [[self stretchContrastAverageKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:inputAvgRed], [NSNumber numberWithFloat:inputAvgGreen], [NSNumber numberWithFloat:inputAvgBlue], [NSNumber numberWithFloat:inputMinRed], [NSNumber numberWithFloat:inputMinGreen], [NSNumber numberWithFloat:inputMinBlue], [NSNumber numberWithFloat:inputMaxRed], [NSNumber numberWithFloat:inputMaxGreen], [NSNumber numberWithFloat:inputMaxBlue]]];
}

@end
