//
//  EdgeGradient.m
//  Chroma
//
//  Created by James Alan Bush on 8/8/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import "EdgeGradient.h"
#import "GlobalCIImage.h"

@implementation EdgeGradient

@synthesize inputImage;

- (CIKernel *)EdgeGradientKernel
{
    static CIKernel *kernelEdgeGradient = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"EdgeGradient")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"EdgeGradientKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelEdgeGradient = [CIKernel kernelWithString:code];
    });
    
    return kernelEdgeGradient;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    [GlobalCIImage sharedSingleton].ciImage = [[self EdgeGradientKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) { return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent)); } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end