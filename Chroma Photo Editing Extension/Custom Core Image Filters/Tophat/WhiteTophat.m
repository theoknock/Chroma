//
//  Tophat.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/10/15.
//
//

#import "WhiteTophat.h"
#import "GlobalCIImage.h"

@implementation WhiteTophat

@synthesize inputImage;

- (CIKernel *)erodeKernel
{
    static CIKernel *kernelErode = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Erode")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ErodeKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelErode = [CIKernel kernelWithString:code];
    });
    
    return kernelErode;
}

- (CIKernel *)dilateKernel
{
    static CIKernel *kernelDilate = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Dilate")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"DilateKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelDilate = [CIKernel kernelWithString:code];
    });
    
    return kernelDilate;
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

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage; //[CIFilter filterWithName:@"ContrastStretch" keysAndValues:kCIInputImageKey, self.inputImage, nil].outputImage;
    
    /*
    [GlobalCIImage sharedSingleton].ciImage = [[self erodeKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    [GlobalCIImage sharedSingleton].ciImage = [[self dilateKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    */
    
    [GlobalCIImage sharedSingleton].ciImage = [[self squareErosionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    [GlobalCIImage sharedSingleton].ciImage = [[self crossDilationKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
