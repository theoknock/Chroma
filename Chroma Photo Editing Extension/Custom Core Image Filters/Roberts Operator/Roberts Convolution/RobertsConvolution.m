//
//  RobertsConvolution.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/22/15.
//
//

#import "RobertsConvolution.h"
#import "GlobalCIImage.h"

@implementation RobertsConvolution

@synthesize inputImage;

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

- (CIImage *)outputImage
{
    const double g = 1.0;
    //const CGFloat weights_v[] = { 1*g, 0*g, 0*g, 0*g, 0*g, 0*g, 0*g, 0*g, -1*g };
    const CGFloat weights_v[] = { 0*g,  0*g, 0*g,
                                  0*g, -1*g, 0*g,
                                  0*g,  1*g, 0*g };
        
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:
               @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
               @"inputWeights", [CIVector vectorWithValues:weights_v count:9],
               @"inputBias", [NSNumber numberWithFloat:1.0],
                                               nil].outputImage;
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByCroppingToRect:cropRectLeft];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;
    
    //const CGFloat weights_h[] = { 0*g, 0*g, 1*g, 0*g, 0*g, 0*g, -1*g, 0*g, 0*g };
/*
    const CGFloat weights_h[] = { 0*g, 0*g, 0*g, 0*g, 1*g, 0*g, 0*g, -1*g, 0*g };
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
              @"inputWeights", [CIVector vectorWithValues:weights_h count:9],
              @"inputBias", [NSNumber numberWithFloat:1.0],
              nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByCroppingToRect:cropRectLeft];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;
*/
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end