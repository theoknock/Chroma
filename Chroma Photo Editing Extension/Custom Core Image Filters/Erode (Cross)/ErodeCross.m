//
//  ErodeCross.m
//  Chroma
//
//  Created by James Alan Bush on 6/26/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "ErodeCross.h"
#import "GlobalCIImage.h"

@implementation ErodeCross

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

- (CIKernel *)erodeCrossKernel
{
    static CIKernel *kernelErodeCross = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"ErodeCross")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ErodeCrossKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelErodeCross = [CIKernel kernelWithString:code];
    });
    
    return kernelErodeCross;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self erodeCrossKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:self.inputRadius.floatValue]]];
}

@end