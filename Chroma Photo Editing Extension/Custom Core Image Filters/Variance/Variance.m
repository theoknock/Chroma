//
//  Variance.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "Variance.h"
#import "GlobalCIImage.h"

@implementation Variance

@synthesize inputImage;

- (CIKernel *)varianceKernel
{
    static CIKernel *kernelVariance = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Variance")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"VarianceKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelVariance = [CIKernel kernelWithString:code];
    });
    
    return kernelVariance;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self varianceKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
