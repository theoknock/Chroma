//
//  AbsoluteDeviation.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/22/15.
//
//

#import "AbsoluteDeviation.h"
#import "GlobalCIImage.h"

@implementation AbsoluteDeviation

@synthesize inputImage;

- (CIKernel *)absoluteDeviationKernel
{
    static CIKernel *kernelAbsoluteDeviation = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"AbsoluteDeviation")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"AbsoluteDeviationKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelAbsoluteDeviation = [CIKernel kernelWithString:code];
    });
    
    return kernelAbsoluteDeviation;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self absoluteDeviationKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
