//
//  ExposureGamma.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/24/15.
//
//

#import <CoreImage/CoreImage.h>

@interface ExposureGamma : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end