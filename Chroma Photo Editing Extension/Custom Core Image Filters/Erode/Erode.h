//
//  Erode.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/27/15.
//
//

#import <CoreImage/CoreImage.h>

@interface Erode : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputRadius;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputRadius;

@end