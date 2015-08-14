//
//  CustomConvolution.h
//  Chroma
//
//  Created by James Alan Bush on 7/3/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CustomConvolution : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputCompassGradient;
    NSNumber *inputThresholdType;
    NSNumber *inputH1;
    NSNumber *inputH2;
    NSNumber *inputH3;
    NSNumber *inputH4;
    NSNumber *inputH5;
    NSNumber *inputH6;
    NSNumber *inputH7;
    NSNumber *inputH8;
    NSNumber *inputH9;
    NSNumber *inputV1;
    NSNumber *inputV2;
    NSNumber *inputV3;
    NSNumber *inputV4;
    NSNumber *inputV5;
    NSNumber *inputV6;
    NSNumber *inputV7;
    NSNumber *inputV8;
    NSNumber *inputV9;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputCompassGradient;
@property (retain, nonatomic) NSNumber *inputThresholdType;
@property (retain, nonatomic) NSNumber *inputH1;
@property (retain, nonatomic) NSNumber *inputH2;
@property (retain, nonatomic) NSNumber *inputH3;
@property (retain, nonatomic) NSNumber *inputH4;
@property (retain, nonatomic) NSNumber *inputH5;
@property (retain, nonatomic) NSNumber *inputH6;
@property (retain, nonatomic) NSNumber *inputH7;
@property (retain, nonatomic) NSNumber *inputH8;
@property (retain, nonatomic) NSNumber *inputH9;
@property (retain, nonatomic) NSNumber *inputV1;
@property (retain, nonatomic) NSNumber *inputV2;
@property (retain, nonatomic) NSNumber *inputV3;
@property (retain, nonatomic) NSNumber *inputV4;
@property (retain, nonatomic) NSNumber *inputV5;
@property (retain, nonatomic) NSNumber *inputV6;
@property (retain, nonatomic) NSNumber *inputV7;
@property (retain, nonatomic) NSNumber *inputV8;
@property (retain, nonatomic) NSNumber *inputV9;

@end