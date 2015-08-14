//
//  MorphologicalEdgeCornerDetection.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/28/15.
//
//

#import <CoreImage/CoreImage.h>

@interface MorphologicalEdgeCornerDetection : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end