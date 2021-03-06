//
//  FASTCornerDetection.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/16/15.
//
//

#import "FASTCornerDetection.h"
#import "GlobalCIImage.h"

@implementation FASTCornerDetection

@synthesize inputImage;

- (CIKernel *)FASTCornerDetectionKernel
{
    static CIKernel *kernelFASTCornerDetection = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"FASTCornerDetection")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"FASTCornerDetectionKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelFASTCornerDetection = [CIKernel kernelWithString:code];
    });
    
    return kernelFASTCornerDetection;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self FASTCornerDetectionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
