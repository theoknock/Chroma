//
//  Magnitude.m
//  Chroma
//
//  Created by James Alan Bush on 8/8/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import "Magnitude.h"
#import "GlobalCIImage.h"

@implementation Magnitude

@synthesize inputImage;

- (CIKernel *)MagnitudeKernel
{
    static CIKernel *kernelMagnitude = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Magnitude")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"MagnitudeKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelMagnitude = [CIKernel kernelWithString:code];
    });
    
    return kernelMagnitude;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    [GlobalCIImage sharedSingleton].ciImage = [[self MagnitudeKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) { return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent)); } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end