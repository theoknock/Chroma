//
//  MorphologicalEdgeCornerDetection.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/28/15.
//
//

#import "MorphologicalEdgeCornerDetection.h"
#import "GlobalCIImage.h"

@implementation MorphologicalEdgeCornerDetection

@synthesize inputImage;

- (CIKernel *)xDilationKernel
{
    static CIKernel *kernelXDilation = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"xDilationKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"xDilationKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelXDilation = [CIKernel kernelWithString:code];
    });
    
    return kernelXDilation;
}

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

- (CIKernel *)crossDilationKernel
{
    static CIKernel *kernelCrossDilation = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"crossDilationKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"crossDilationKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelCrossDilation = [CIKernel kernelWithString:code];
    });
    
    return kernelCrossDilation;
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

- (CIKernel *)absoluteDifferenceKernel
{
    static CIKernel *kernelAbsoluteDifference = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"absoluteDifferenceKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"absoluteDifferenceKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelAbsoluteDifference = [CIKernel kernelWithString:code];
    });
    
    return kernelAbsoluteDifference;
}

/*
- (CGRect)regionOf:(int)samplerIndex destRect:(CGRect)r userInfo:obj
{
    if (samplerIndex == 0 || samplerIndex == 1) {
        return CGRectMake(0, 0, CGRectGetWidth(self.inputImage.extent), CGRectGetHeight(self.inputImage.extent));
    }
    return CGRectMake(0, 0, CGRectGetWidth(self.inputImage.extent), CGRectGetHeight(self.inputImage.extent));;
}
*/

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    /*
    CIImage *inputImageB = [[self diamondErosionKernel] applyWithExtent:self.inputImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth(self.inputImage.extent), CGRectGetHeight(self.inputImage.extent));
    } arguments:@[self.inputImage]];

    CIImage *inputImageC = [[self crossDilationKernel] applyWithExtent:self.inputImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth(self.inputImage.extent), CGRectGetHeight(self.inputImage.extent));
    } arguments:@[self.inputImage]];
    */

    return [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [[self squareErosionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]], kCIInputBackgroundImageKey, [[self xDilationKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]], nil].outputImage;
}

@end