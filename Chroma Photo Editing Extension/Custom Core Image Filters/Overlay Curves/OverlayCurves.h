//
//  H(S-V).h
//  Photo Filter
//
//  Created by James Alan Bush on 6/15/15.
//
//

#import <CoreImage/CoreImage.h>

@interface OverlayCurves : CIFilter
{
    CIImage  *inputImage;
    NSNumber *inputCurve;
    NSNumber *inputMinContrastValue;
    NSNumber *inputMaxContrastValue;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputCurve;
@property (retain, nonatomic) NSNumber *inputMinContrastValue;
@property (retain, nonatomic) NSNumber *inputMaxContrastValue;

@end
