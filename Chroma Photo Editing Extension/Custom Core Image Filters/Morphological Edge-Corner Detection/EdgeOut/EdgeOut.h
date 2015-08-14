//
//  EdgeOut.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/11/15.
//
//

#import <CoreImage/CoreImage.h>

@interface EdgeOut : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end