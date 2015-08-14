//
//  DilateDiamond.m
//  Chroma
//
//  Created by James Alan Bush on 6/26/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "DilateDiamond.h"
#import "GlobalCIImage.h"

@implementation DilateDiamond

@synthesize inputImage;
@synthesize inputRadius;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputRadius" :
                 @{
                     kCIAttributeMin       : @3.0,
                     kCIAttributeMax       : @9.0,
                     kCIAttributeDefault   : @3.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     }
             };
}

- (CIKernel *)dilateDiamondKernel
{
    static CIKernel *kernelDilateDiamond = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"DilateDiamond")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"DilateDiamondKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelDilateDiamond = [CIKernel kernelWithString:code];
    });
    
    return kernelDilateDiamond;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self dilateDiamondKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:self.inputRadius.floatValue]]];
}

@end
