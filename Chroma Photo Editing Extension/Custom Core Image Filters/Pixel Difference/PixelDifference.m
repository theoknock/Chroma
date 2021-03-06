//
//  PixelDifference.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/22/15.
//
//

#import "PixelDifference.h"
#import "GlobalCIImage.h"

@implementation PixelDifference

@synthesize inputImage;

- (CIImage *)outputImage
{
    const double g = 1.0;
    //const CGFloat weights_v[] = { 1*g, 0*g, 0*g, 0*g, 0*g, 0*g, 0*g, 0*g, -1*g };
    const CGFloat weights_v[] = { 0*g,  0*g, 0*g,
        0*g,  1*g, 0*g,
        0*g, -1*g, 0*g };
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
    [GlobalCIImage sharedSingleton].ciImage = [[CIFilter filterWithName:@"CIConvolution3X3" keysAndValues:
                                                @"inputImage", [GlobalCIImage sharedSingleton].ciImage,
                                                @"inputWeights", [CIVector vectorWithValues:weights_v count:9],
                                                @"inputBias", [NSNumber numberWithFloat:1.0],
                                                nil].outputImage imageByCroppingToRect:cropRectLeft];
    
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