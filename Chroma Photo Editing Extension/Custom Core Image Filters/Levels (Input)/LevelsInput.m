//
//  LevelsInput.m
//  Chroma
//
//  Created by James Alan Bush on 6/29/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "LevelsInput.h"
#import "GlobalCIImage.h"

@implementation LevelsInput

@synthesize inputImage;
@synthesize inputMinInput;
@synthesize inputGamma;
@synthesize inputMaxInput;
@synthesize inputMinOutput;
@synthesize inputMaxOutput;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputMinInput" :
                 @{
                     kCIAttributeMin       : @-3.0,
                     kCIAttributeMax       : @3.0,
                     kCIAttributeDefault   : @0.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputGamma" :
                 @{
                     kCIAttributeMin       : @0.0,
                     kCIAttributeMax       : @5.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputMaxInput" :
                 @{
                     kCIAttributeMin       : @-3.0,
                     kCIAttributeMax       : @3.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputMinOutput" :
                 @{
                     kCIAttributeMin       : @-3.0,
                     kCIAttributeMax       : @3.0,
                     kCIAttributeDefault   : @0.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputMaxOutput" :
                 @{
                     kCIAttributeMin       : @-3.0,
                     kCIAttributeMax       : @3.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     }
             };
}

- (CIKernel *)levelsInputKernel
{
    static CIKernel *kernelLevelsInput = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"LevelsInput")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"InputLevelsKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelLevelsInput = [CIKernel kernelWithString:code];
    });
    
    return kernelLevelsInput;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self levelsInputKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:inputMinInput.floatValue], [NSNumber numberWithFloat:inputGamma.floatValue], [NSNumber numberWithFloat:inputMaxInput.floatValue], [NSNumber numberWithFloat:inputMinOutput.floatValue], [NSNumber numberWithFloat:inputMaxOutput.floatValue]]];
}

@end
