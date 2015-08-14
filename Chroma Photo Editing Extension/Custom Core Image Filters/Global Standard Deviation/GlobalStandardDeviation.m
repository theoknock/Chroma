//
//  GlobalStandardDeviation.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "GlobalStandardDeviation.h"
#import "GlobalContext.h"
#import "GlobalCIImage.h"

@implementation GlobalStandardDeviation

@synthesize inputImage;

- (CIKernel *)globalStandardDeviationKernel
{
    static CIKernel *kernelGlobalStandardDeviation = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"GlobalStandardDeviation")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"GlobalStandardDeviationKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelGlobalStandardDeviation = [CIKernel kernelWithString:code];
    });
    
    return kernelGlobalStandardDeviation;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    CGRect inputExtent = [[GlobalCIImage sharedSingleton].ciImage extent];
    CIVector *extent = [CIVector vectorWithX:inputExtent.origin.x
                                           Y:inputExtent.origin.y
                                           Z:inputExtent.size.width
                                           W:inputExtent.size.height];
    CIImage *inputAverage = [CIFilter filterWithName:@"CIAreaAverage" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputExtentKey, extent, nil].outputImage;
    size_t rowBytes = 4; // ARGB has 4 components
    uint8_t byteBuffer[rowBytes]; // Buffer to render into
    
    [[GlobalContext sharedSingleton].ciContext render:inputAverage toBitmap:byteBuffer rowBytes:rowBytes bounds:[inputAverage extent] format:kCIFormatRGBA8 colorSpace:nil];
    
    const uint8_t* pixel = &byteBuffer[0];
    /*
    uint8_t red = pixel[0];
    uint8_t green = pixel[1];
    uint8_t blue = pixel[2];
    uint8_t alpha = pixel[3];
    */
    float inputRed   = [NSNumber numberWithFloat:pixel[0]].floatValue / 255.0;
    float inputGreen = [NSNumber numberWithFloat:pixel[1]].floatValue / 255.0;
    float inputBlue  = [NSNumber numberWithFloat:pixel[2]].floatValue / 255.0;
    float inputAlpha = [NSNumber numberWithFloat:pixel[3]].floatValue / 255.0;
    // NSLog(@"%hhu, %hhu, %hhu, %hhu\n", red, green, blue, alpha);
    // NSLog(@"%f, %f, %f, %f\n", inputRed, inputGreen, inputBlue, inputAlpha);

    float inputHeight = [NSNumber numberWithFloat:inputExtent.size.height].floatValue;
    
    return [[self globalStandardDeviationKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:inputHeight], [NSNumber numberWithFloat:inputRed], [NSNumber numberWithFloat:inputGreen], [NSNumber numberWithFloat:inputBlue], [NSNumber numberWithFloat:inputAlpha]]];
}

@end
