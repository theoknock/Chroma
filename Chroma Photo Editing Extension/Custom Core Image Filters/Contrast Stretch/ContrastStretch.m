//
//  ContrastStretch.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "ContrastStretch.h"
#import "GlobalContext.h"
#import "GlobalCIImage.h"

@implementation ContrastStretch

@synthesize inputImage;

- (CIKernel *)contrastStretchKernel
{
    static CIKernel *kernelContrastStretch = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"ContrastStretch")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ContrastStretchKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelContrastStretch = [CIKernel kernelWithString:code];
    });
    
    return kernelContrastStretch;
}

- (CIImage *)outputImage
{
    
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
        
        CGRect inputExtent = [[GlobalCIImage sharedSingleton].ciImage extent];
        CIVector *extent = [CIVector vectorWithX:inputExtent.origin.x
                                               Y:inputExtent.origin.y
                                               Z:inputExtent.size.width
                                               W:inputExtent.size.height];
    
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
    
    // Per Apple's documentation, kCIInputExtentKey is not available for iOS
    CIImage *inputMaximum = [[CIFilter filterWithName:@"CIAreaMaximum" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputExtent", extent, nil].outputImage imageByCroppingToRect:cropRectLeft];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;
    
        int width = inputMaximum.extent.size.width;
        int height = inputMaximum.extent.size.height;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), [[GlobalContext sharedSingleton].ciContext createCGImage:inputMaximum fromRect:CGRectMake(0, 0, width, height) format:kCIFormatARGB8 colorSpace:colorSpace]);
        CGColorSpaceRelease(colorSpace);
    
    unsigned int *colorData = CGBitmapContextGetData(context);
    float inputRed = 0.0;
    float inputGreen = 0.0;
    float inputBlue = 0.0;

    for (int i = 0; i < width * height; i++)
    {
        unsigned int color = *colorData;
        
        short a = color & 0xFF;
        short r = (color >> 8) & 0xFF;
        short g = (color >> 16) & 0xFF;
        short b = (color >> 24) & 0xFF;
        NSLog(@"CIAreaMaximum output: %d, %d, %d, %d", r, g, b, a);
        inputRed   = r;
        inputGreen = g;
        inputBlue  = b;
        a = r = g = b = 0;
        *colorData = (unsigned int)(r << 8) + ((unsigned int)(g) << 16) + ((unsigned int)(b) << 24) + ((unsigned int)(a));
        
        colorData++;
    }
    
        CGContextRelease(context);
    
    [GlobalCIImage sharedSingleton].ciImage = [[self contrastStretchKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:inputRed], [NSNumber numberWithFloat:inputGreen], [NSNumber numberWithFloat:inputBlue]]];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
