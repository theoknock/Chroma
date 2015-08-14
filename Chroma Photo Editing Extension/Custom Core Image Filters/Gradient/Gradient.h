//
//  Gradient.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/10/15.
//
//

#import <CoreImage/CoreImage.h>

@interface Gradient : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end