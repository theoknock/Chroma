//
//  RMS.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/22/15.
//
//

#import "RMS.h"
#import "GlobalCIImage.h"

@implementation RMS

@synthesize inputImage;

- (CIKernel *)rmsKernel
{
    static CIKernel *kernelRMS = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"RMS")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"RMSKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelRMS = [CIKernel kernelWithString:code];
    });
    
    return kernelRMS;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self rmsKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end