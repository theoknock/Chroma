//
//  MeanMinMax.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/22/15.
//
//

#import "MeanMinMax.h"
#import "GlobalCIImage.h"

@implementation MeanMinMax

@synthesize inputImage;

- (CIKernel *)meanMinMaxKernel
{
    static CIKernel *kernelMeanMinMax = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"MeanMinMax")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"MeanMinMaxKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelMeanMinMax = [CIKernel kernelWithString:code];
    });
    
    return kernelMeanMinMax;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self meanMinMaxKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
