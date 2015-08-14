//
//  LaplacianConvolution.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "LaplacianConvolution.h"
#import "GlobalCIImage.h"

@implementation LaplacianConvolution

@synthesize inputImage;

- (CIImage *)outputImage
{
    // VARIATION 1
    /*
     const CGFloat weights_v[] = { 1*g, 1,  1*g,
     1*g, -8,  1*g,
     1*g,  1,  1*g};
     */
    
    // SIMPLE
    /*
     const CGFloat weights_v[] = { 0*g, 1,  0*g,
     1*g, -4,  1*g,
     0*g,  1,  0*g};
     */
    
    // VARIATION 2
    /*
     const CGFloat weights_v[] = { 2*g, -1,  2*g,
     -1*g, -4,  -1*g,
     2*g,  -1,    2*g};
     */
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    const double g = 1.0;
    const CGFloat weights_v[] = { 2*g, -1,  2*g,
        -1*g, -4,  -1*g,
        2*g,  -1,  2*g};
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];

    [GlobalCIImage sharedSingleton].ciImage = [[CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:
               @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
               @"inputWeights", [CIVector vectorWithValues:weights_v count:9],
               @"inputBias", [NSNumber numberWithFloat:1.0],
               nil].outputImage imageByCroppingToRect:cropRectLeft];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
        
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end