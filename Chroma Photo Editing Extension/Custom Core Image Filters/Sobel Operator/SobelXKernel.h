//
//  SobelXKernel.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/18/15.
//
//

#import <CoreImage/CoreImage.h>

@interface SobelXKernel : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end