//
//  FourDirectionalMinMax.m
//  Chroma
//
//  Created by James Alan Bush on 7/5/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "FourDirectionalMinMax.h"
#import "GlobalCIImage.h"

@implementation FourDirectionalMinMax

@synthesize inputImage;

- (CIKernel *)fourDirectionalMinMaxKernel
{
    static CIKernel *kernelFourDirectionalMinMax = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"FourDirectionalMinMax")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"FourDirectionalMinMaxKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelFourDirectionalMinMax = [CIKernel kernelWithString:code];
    });
    
    return kernelFourDirectionalMinMax;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self fourDirectionalMinMaxKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
