//
//  Maximum.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "Maximum.h"
#import "GlobalCIImage.h"

@implementation Maximum

@synthesize inputImage;

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [CIFilter filterWithName:@"CIMaximumComponent" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
}


@end