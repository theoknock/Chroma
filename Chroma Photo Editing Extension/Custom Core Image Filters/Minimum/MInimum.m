//
//  MInimum.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "Minimum.h"
#import "GlobalCIImage.h"

@implementation Minimum

@synthesize inputImage;

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [CIFilter filterWithName:@"CIMinimumComponent" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
}


@end