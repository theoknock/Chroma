//
//  Scharr.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/24/15.
//
//

#import "Scharr.h"
#import "GlobalCIImage.h"

@implementation Scharr

@synthesize inputImage;

- (CIImage *)outputImage
{
    if (inputImage == nil)
        return nil;
    
    double g = 1.0;
    
    const CGFloat weights_h[] = {-3*g,-10*g,-3*g,
        0,   0,   0,
        3*g, 10*g, 3*g};
    
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [[CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputWeights", [CIVector vectorWithValues:weights_h count:9], @"inputBias", [NSNumber numberWithFloat:1.0], nil].outputImage imageByCroppingToRect:cropRectLeft], @"inputRectangle", cropRect, nil].outputImage;

    const CGFloat weights_v[] = { -3*g, 0, 3*g,
        -10*g, 0, 10*g,
        -3*g, 0, 3*g};
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [[CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputWeights", [CIVector vectorWithValues:weights_v count:9], @"inputBias", [NSNumber numberWithFloat:1.0], nil].outputImage imageByCroppingToRect:cropRectLeft], @"inputRectangle", cropRect, nil].outputImage;


    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    //[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISubtractBlendMode" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputBackgroundImageKey, self.inputImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end