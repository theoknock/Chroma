//
//  SobelConvolution.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "SobelConvolution.h"
#import "GlobalCIImage.h"

@implementation SobelConvolution

@synthesize inputImage;

- (CIKernel *)sobelConvolutionKernel
{
    static CIKernel *kernelSobelConvolution = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"SobelConvolutionKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"SobelConvolutionKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelSobelConvolution = [CIKernel kernelWithString:code];
    });
    
    return kernelSobelConvolution;
}

- (CIImage *)outputImage
{
    const CGFloat weights[] = {
        0.00296901674395065, 0.013306209891014005, 0.021938231279715042, 0.013306209891014005, 0.00296901674395065,
        0.013306209891014005, 0.05963429543618023, 0.09832033134884507, 0.05963429543618023, 0.013306209891014005,
        0.021938231279715042, 0.09832033134884507, 0.16210282163712417, 0.09832033134884507, 0.021938231279715042,
        0.013306209891014005, 0.05963429543618023, 0.09832033134884507, 0.05963429543618023, 0.013306209891014005,
        0.00296901674395065, 0.013306209891014005, 0.021938231279715042, 0.013306209891014005, 0.00296901674395065
    };
    
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;

    
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
    [GlobalCIImage sharedSingleton].ciImage = [[CIFilter filterWithName:@"CIConvolution5X5" keysAndValues:
               @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
               @"inputWeights", [CIVector vectorWithValues:weights count:25],
               @"inputBias", @1.0,
               nil].outputImage imageByCroppingToRect:cropRectLeft];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;
    

    /*
    CIImage *[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ContrastStretch" keysAndValues:kCIInputImageKey, self.inputImage, nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[self sobelConvolutionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    */
    
    /*[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISubtractBlendMode" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputBackgroundImage", self.inputImage, nil].outputImage;*/
        
    /*
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"SobelEdgeH" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    CGRect rect = [self.inputImage extent];
    rect.origin = CGPointZero;
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByCroppingToRect:cropRectLeft];
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"SobelEdgeV" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    [GlobalCIImage sharedSingleton].ciImage = [[GlobalCIImage sharedSingleton].ciImage imageByCroppingToRect:cropRectLeft];
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;
    */
    
    /*
    double g = 1.0;
    
    const CGFloat weights[] = { 1*g, 0, -1*g,
        2*g, 0, -2*g,
        1*g, 0, -1*g};

    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:
              @"inputImage", inputImage,
              @"inputWeights", [CIVector vectorWithValues:weights count:9],
              @"inputBias", @0.5,
              nil].outputImage;

    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
              @"inputBackgroundImage", [CIImage imageWithColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:1]],
              nil].outputImage;
    
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIColorPolynomial" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
              @"inputRedCoefficients", [CIVector vectorWithX:1.0 Y:-4.0 Z:4.0 W:0.0],
              @"inputGreenCoefficients", [CIVector vectorWithX:1.0 Y:-4.0 Z:4.0 W:0.0],
              @"inputBlueCoefficients", [CIVector vectorWithX:1.0 Y:-4.0 Z:4.0 W:0.0],
              nil].outputImage;

    const CGFloat weights_v[] = {-1*g,-2*g,-1*g,
        0,   0,   0,
        1*g, 2*g, 1*g};

    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:
              @"inputImage", inputImage,
              @"inputWeights", [CIVector vectorWithValues:weights_v count:9],
              @"inputBias", @0.5,
              nil].outputImage;

    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
              @"inputBackgroundImage", [CIImage imageWithColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:1]],
              nil].outputImage;
    
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIColorPolynomial" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
              @"inputRedCoefficients", [CIVector vectorWithX:1.0 Y:-4.0 Z:4.0 W:0.0],
              @"inputGreenCoefficients", [CIVector vectorWithX:1.0 Y:-4.0 Z:4.0 W:0.0],
              @"inputBlueCoefficients", [CIVector vectorWithX:1.0 Y:-4.0 Z:4.0 W:0.0],
              nil].outputImage;
    */
        
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
