//
//  ShiftedDataVariance.h
//  Chroma
//
//  Created by James Alan Bush on 7/7/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface ShiftedDataVariance : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputIterations;
    NSNumber *inputUnits;
    NSNumber *inputNorth;
    NSNumber *inputSouth;
    NSNumber *inputEast;
    NSNumber *inputWest;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputIterations;
@property (retain, nonatomic) NSNumber *inputUnits;
@property (retain, nonatomic) NSNumber *inputNorth;
@property (retain, nonatomic) NSNumber *inputSouth;
@property (retain, nonatomic) NSNumber *inputEast;
@property (retain, nonatomic) NSNumber *inputWest;

@end