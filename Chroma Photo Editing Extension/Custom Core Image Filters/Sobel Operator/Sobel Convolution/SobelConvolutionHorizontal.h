//
//  SobelConvolutionHorizontal.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import <CoreImage/CoreImage.h>

@interface SobelConvolutionHorizontal : CIFilter
{
    CIImage *inputImage;
}
@property (retain, nonatomic) CIImage *inputImage;

@end