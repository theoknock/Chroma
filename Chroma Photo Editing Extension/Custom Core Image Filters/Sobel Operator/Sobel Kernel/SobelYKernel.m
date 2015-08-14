//
//  SobelKernel.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "SobelYKernel.h"
#import "GlobalCIImage.h"

@implementation SobelYKernel

@synthesize inputImage;

- (CIKernel *)sobelYKernel
{
    static CIKernel *kernelSobelY = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"SobelYKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"SobelYKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelSobelY = [CIKernel kernelWithString:code];
    });
    
    return kernelSobelY;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self sobelYKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
