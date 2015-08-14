//
//  DilateX.m
//  Chroma
//
//  Created by James Alan Bush on 6/26/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "DilateX.h"
#import "GlobalCIImage.h"

@implementation DilateX

@synthesize inputImage;
@synthesize inputRadius;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputRadius" :
                 @{
                     kCIAttributeMin       : @3.0,
                     kCIAttributeMax       : @9.0,
                     kCIAttributeDefault   : @3.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     }
             };
}

- (CIKernel *)dilateXKernel
{
    static CIKernel *kernelDilateX = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"DilateX")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"DilateXKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelDilateX = [CIKernel kernelWithString:code];
    });
    
    return kernelDilateX;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self dilateXKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:self.inputRadius.floatValue]]];
}

@end
