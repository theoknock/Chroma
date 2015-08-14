//
//  EdgeIn.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/11/15.
//
//

#import "EdgeIn.h"
#import "GlobalCIImage.h"

@implementation EdgeIn

@synthesize inputImage;

- (CIKernel *)diamondErosionKernel
{
    static CIKernel *kernelDiamondErosion = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"diamondErosionKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"diamondErosionKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelDiamondErosion = [CIKernel kernelWithString:code];
    });
    
    return kernelDiamondErosion;
}

- (CIKernel *)squareErosionKernel
{
    static CIKernel *kernelSquareErosion = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"squareErosionKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ErodeKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelSquareErosion = [CIKernel kernelWithString:code];
    });
    
    return kernelSquareErosion;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage; //[CIFilter filterWithName:@"ContrastStretch" keysAndValues:kCIInputImageKey, self.inputImage, nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[self diamondErosionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
            return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
        } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];

    [GlobalCIImage sharedSingleton].ciImage = [[self squareErosionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
