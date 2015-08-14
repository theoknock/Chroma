//
//  AbsoluteDeviation.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/22/15.
//
//

#import <CoreImage/CoreImage.h>

@interface AbsoluteDeviation : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end