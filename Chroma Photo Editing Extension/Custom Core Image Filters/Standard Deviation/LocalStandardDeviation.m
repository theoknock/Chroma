//
//  StandardDeviation.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "LocalStandardDeviation.h"
#import "GlobalCIImage.h"

@implementation LocalStandardDeviation

@synthesize inputImage;

- (CIKernel *)localStandardDeviationKernel
{
    static CIKernel *kernelLocalStandardDeviation = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"LocalStandardDeviation")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"LocalStandardDeviationKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelLocalStandardDeviation = [CIKernel kernelWithString:code];
    });
    
    return kernelLocalStandardDeviation;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self localStandardDeviationKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
