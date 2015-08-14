//
//  H(S-V).h
//  Photo Filter
//
//  Created by James Alan Bush on 6/15/15.
//
//

#import <CoreImage/CoreImage.h>

@interface BushCurve : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputMinContrastValue;
    NSNumber *inputMaxContrastValue;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputMinContrastValue;
@property (retain, nonatomic) NSNumber *inputMaxContrastValue;

@end
