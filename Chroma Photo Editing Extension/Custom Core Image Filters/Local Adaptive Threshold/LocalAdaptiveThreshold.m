//
//  LocalAdaptiveThreshold.m
//  Chroma
//
//  Created by James Alan Bush on 7/5/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "LocalAdaptiveThreshold.h"
#import "GlobalCIImage.h"

@implementation LocalAdaptiveThreshold

@synthesize inputImage;
@synthesize inputThresholdType;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputThresholdType" :
                 @{
                     kCIAttributeMin       : @1.0,
                     kCIAttributeMax       : @4.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     }
                };
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
    return [[self localAdaptiveThresholdingKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:self.inputThresholdType.floatValue]]];
}

@end