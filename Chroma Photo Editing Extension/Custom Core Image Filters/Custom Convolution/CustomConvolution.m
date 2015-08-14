//
//  CustomConvolution.m
//  Chroma
//
//  Created by James Alan Bush on 7/3/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "CustomConvolution.h"
#import "GlobalCIImage.h"

@implementation CustomConvolution

@synthesize inputImage;
@synthesize inputCompassGradient;
@synthesize inputThresholdType;
@synthesize inputH1;
@synthesize inputH2;
@synthesize inputH3;
@synthesize inputH4;
@synthesize inputH5;
@synthesize inputH6;
@synthesize inputH7;
@synthesize inputH8;
@synthesize inputH9;
@synthesize inputV1;
@synthesize inputV2;
@synthesize inputV3;
@synthesize inputV4;
@synthesize inputV5;
@synthesize inputV6;
@synthesize inputV7;
@synthesize inputV8;
@synthesize inputV9;

- (CIKernel *)customConvolutionKernel
{
    static CIKernel *kernelCustomConvolution = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"CustomConvolution")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"CustomConvolutionKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelCustomConvolution = [CIKernel kernelWithString:code];
    });
    
    return kernelCustomConvolution;
}

- (CIKernel *)localAdaptiveThresholdingKernel
{
    static CIKernel *kernelLocalAdaptiveThresholding = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"LocalAdaptiveThresholding")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"LocalAdaptiveThresholdingKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelLocalAdaptiveThresholding = [CIKernel kernelWithString:code];
    });
    
    return kernelLocalAdaptiveThresholding;
}



- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[self customConvolutionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:inputCompassGradient.floatValue], [NSNumber numberWithFloat:inputH1.floatValue],[NSNumber numberWithFloat:inputH2.floatValue], [NSNumber numberWithFloat:inputH3.floatValue], [NSNumber numberWithFloat:inputH4.floatValue], [NSNumber numberWithFloat:inputH5.floatValue], [NSNumber numberWithFloat:inputH6.floatValue], [NSNumber numberWithFloat:inputH7.floatValue], [NSNumber numberWithFloat:inputH8.floatValue], [NSNumber numberWithFloat:inputH9.floatValue], [NSNumber numberWithFloat:inputV1.floatValue], [NSNumber numberWithFloat:inputV2.floatValue], [NSNumber numberWithFloat:inputV3.floatValue], [NSNumber numberWithFloat:inputV4.floatValue], [NSNumber numberWithFloat:inputV5.floatValue], [NSNumber numberWithFloat:inputV6.floatValue], [NSNumber numberWithFloat:inputV7.floatValue], [NSNumber numberWithFloat:inputV8.floatValue], [NSNumber numberWithFloat:inputV9.floatValue]]];
    
    return [[self localAdaptiveThresholdingKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:self.inputThresholdType.floatValue]]];
}

@end