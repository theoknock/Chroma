//
//  PrewittKernel.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "PrewittKernel.h"
#import "GlobalCIImage.h"

@implementation PrewittKernel

@synthesize inputImage;

- (CIKernel *)prewittKernel
{
    static CIKernel *kernelPrewitt = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"PrewittKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"PrewittKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelPrewitt = [CIKernel kernelWithString:code];
    });
    
    return kernelPrewitt;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self prewittKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end