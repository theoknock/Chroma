//
//  BlackTophat.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/10/15.
//
//

#import <CoreImage/CoreImage.h>

@interface BlackTophat : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputRadius;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputRadius;



@end