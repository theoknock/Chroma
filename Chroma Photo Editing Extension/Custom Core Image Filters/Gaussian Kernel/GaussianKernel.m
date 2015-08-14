//
//  GaussianKernel.m
//  Chroma
//
//  Created by James Alan Bush on 7/12/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import "GaussianKernel.h"
#import "GlobalCIImage.h"

@implementation GaussianKernel

@synthesize inputImage;
@synthesize inputRadius;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputRadius" :
                 @{
                     kCIAttributeMin       : @0.0,
                     kCIAttributeMax       : @15.0,
                     kCIAttributeDefault   : @0.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     }
             };
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage; // [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, self.inputImage, @"inputRadius", [NSNumber numberWithFloat:inputRadius.floatValue], nil].outputImage;
    
    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
    [GlobalCIImage sharedSingleton].ciImage = [[CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, self.inputImage, @"inputRadius", [NSNumber numberWithFloat:inputRadius.floatValue], nil].outputImage imageByCroppingToRect:cropRectLeft];
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputRectangle", cropRect, nil].outputImage;

    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
