//
//  LocalContrastStretch.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/5/15.
//
//

#import "LocalContrastStretch.h"
#import "GlobalCIImage.h"

@implementation LocalContrastStretch

@synthesize inputImage;

- (CIKernel *)localContrastStretchKernel
{
    static CIKernel *kernelLocalContrastStretch = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"LocalContrastStretch")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"LocalContrastStretchKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelLocalContrastStretch = [CIKernel kernelWithString:code];
    });
    
    return kernelLocalContrastStretch;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    //[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIMaximumComponent" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[self localContrastStretchKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    //CIImage *original = [CIFilter filterWithName:@"CIMinimumComponent" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    //[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISubtractBlendMode" keysAndValues:kCIInputImageKey, original, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
