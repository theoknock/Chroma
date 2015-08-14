//
//  Open.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/27/15.
//
//

#import <CoreImage/CoreImage.h>

@interface Open : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end