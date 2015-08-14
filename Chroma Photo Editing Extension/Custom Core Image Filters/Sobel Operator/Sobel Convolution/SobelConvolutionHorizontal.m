//
//  SobelConvolutionHorizontal.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "SobelConvolutionHorizontal.h"
#import "GlobalCIImage.h"

@implementation SobelConvolutionHorizontal

@synthesize inputImage;

- (CIImage *)outputImage
{
    if (inputImage == nil)
        return nil;
    else
        [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    double g = 1.0;
    
    const CGFloat weights[] = { 1*g, 0, -1*g,
        2*g, 0, -2*g,
        1*g, 0, -1*g};
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
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
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end