//
//  SobelXKernel.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/18/15.
//
//

#import "SobelXKernel.h"
#import "GlobalCIImage.h"

@implementation SobelXKernel

@synthesize inputImage;

- (CIKernel *)sobelXKernel
{
    static CIKernel *kernelSobelX = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"SobelXKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"SobelXKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelSobelX = [CIKernel kernelWithString:code];
    });
    
    return kernelSobelX;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self sobelXKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
