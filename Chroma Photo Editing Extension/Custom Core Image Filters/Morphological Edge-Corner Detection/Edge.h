//
//  Edge.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/11/15.
//
//

#import <CoreImage/CoreImage.h>

@interface Edge : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputRadius;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputRadius;

@end