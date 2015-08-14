//
//  MedianUnsharp.m
//  Chroma
//
//  Created by James Alan Bush on 6/29/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "MedianUnsharp.h"
#import "GlobalCIImage.h"

@implementation MedianUnsharp

@synthesize inputImage;

- (CIKernel *)medianUnsharpKernel
{
    static CIKernel *kernelMedianUnsharp = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"MedianUnsharp")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"MedianUnsharpKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelMedianUnsharp = [CIKernel kernelWithString:code];
    });
    
    return kernelMedianUnsharp;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self medianUnsharpKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
