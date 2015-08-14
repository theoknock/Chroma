//
//  ShiftedDataVariance.m
//  Chroma
//
//  Created by James Alan Bush on 7/7/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "ShiftedDataVariance.h"
#import "GlobalCIImage.h"

@implementation ShiftedDataVariance

@synthesize inputImage;
@synthesize inputIterations;
@synthesize inputUnits;
@synthesize inputNorth;
@synthesize inputSouth;
@synthesize inputEast;
@synthesize inputWest;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputIterations" :
                 @{
                     kCIAttributeMin       : @1.0,
                     kCIAttributeMax       : @4.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputUnits" :
                 @{
                     kCIAttributeMin       : @1.0,
                     kCIAttributeMax       : @4.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputNorth" :
                 @{
                     kCIAttributeMin       : @1.0,
                     kCIAttributeMax       : @9.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputSouth" :
                 @{
                     kCIAttributeMin       : @1.0,
                     kCIAttributeMax       : @9.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputEast" :
                 @{
                     kCIAttributeMin       : @1.0,
                     kCIAttributeMax       : @9.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             @"inputWest" :
                 @{
                     kCIAttributeMin       : @1.0,
                     kCIAttributeMax       : @9.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     }
             };
}


- (CIKernel *)shiftedDataVarianceKernel
{
    static CIKernel *kernelShiftedDataVariance = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"ShiftedDataVarianceKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ShiftedDataVarianceKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelShiftedDataVariance = [CIKernel kernelWithString:code];
    });
    
    return kernelShiftedDataVariance;
}
- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    for (int i = 0; i < inputIterations.intValue; i++)
    {
        [GlobalCIImage sharedSingleton].ciImage = [[self shiftedDataVarianceKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) { return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent)); } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:inputUnits.floatValue], [NSNumber numberWithFloat:inputNorth.floatValue], [NSNumber numberWithFloat:inputSouth.floatValue], [NSNumber numberWithFloat:inputEast.floatValue], [NSNumber numberWithFloat:inputWest.floatValue]]];
    }
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
