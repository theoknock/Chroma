//
//  SobelConvolutionVertical.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "SobelConvolutionVertical.h"
#import "GlobalCIImage.h"

@implementation SobelConvolutionVertical

@synthesize inputImage;

- (CIImage *)outputImage
{
    if (inputImage == nil)
        return nil;
    else
        [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    const CGFloat weights[] = {
        0.00296901674395065, 0.013306209891014005, 0.021938231279715042, 0.013306209891014005, 0.00296901674395065,
        0.013306209891014005, 0.05963429543618023, 0.09832033134884507, 0.05963429543618023, 0.013306209891014005,
        0.021938231279715042, 0.09832033134884507, 0.16210282163712417, 0.09832033134884507, 0.021938231279715042,
        0.013306209891014005, 0.05963429543618023, 0.09832033134884507, 0.05963429543618023, 0.013306209891014005,
        0.00296901674395065, 0.013306209891014005, 0.021938231279715042, 0.013306209891014005, 0.00296901674395065
    };
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIConvolution5X5" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
              @"inputWeights", [CIVector vectorWithValues:weights count:25],
              @"inputBias", @0.5,
              nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
              @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
              @"inputBackgroundImage", [GlobalCIImage sharedSingleton].ciImage,
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
