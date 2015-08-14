//
//  StretchContrastAverage.h
//  Chroma
//
//  Created by James Alan Bush on 7/17/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>
@import CoreGraphics;

@interface StretchContrastAverage : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end