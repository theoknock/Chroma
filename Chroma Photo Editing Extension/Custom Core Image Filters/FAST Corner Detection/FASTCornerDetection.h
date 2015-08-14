//
//  FASTCornerDetection.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/16/15.
//
//

#import <CoreImage/CoreImage.h>

@interface FASTCornerDetection : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end