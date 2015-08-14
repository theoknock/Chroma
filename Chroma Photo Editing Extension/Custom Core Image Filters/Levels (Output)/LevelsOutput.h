//
//  LevelsOutput.h
//  Chroma
//
//  Created by James Alan Bush on 6/29/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface LevelsOutput : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputMinInput;
    NSNumber *inputGamma;
    NSNumber *inputMaxInput;
    NSNumber *inputMinOutput;
    NSNumber *inputMaxOutput;
}

@property (retain, nonatomic) CIImage  *inputImage;
@property (retain, nonatomic) NSNumber *inputMinInput;
@property (retain, nonatomic) NSNumber *inputGamma;
@property (retain, nonatomic) NSNumber *inputMaxInput;
@property (retain, nonatomic) NSNumber *inputMinOutput;
@property (retain, nonatomic) NSNumber *inputMaxOutput;

@end