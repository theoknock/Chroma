//
//  dx.m
//  Chroma
//
//  Created by James Alan Bush on 8/7/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import "dx.h"
#import "GlobalCIImage.h"

@implementation dx

@synthesize inputImage;

- (CIKernel *)dxKernel
{
    static CIKernel *kerneldx = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"dx")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"dxKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kerneldx = [CIKernel kernelWithString:code];
    });
    
    return kerneldx;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    [GlobalCIImage sharedSingleton].ciImage = [[self dxKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) { return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent)); } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];

    return [GlobalCIImage sharedSingleton].ciImage;
}

@end