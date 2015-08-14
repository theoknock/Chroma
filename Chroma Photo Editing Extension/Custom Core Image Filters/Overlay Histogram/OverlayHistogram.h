//
//  OverlayHistogram.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/22/15.
//
//

#import <CoreImage/CoreImage.h>

@interface OverlayHistogram : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end
