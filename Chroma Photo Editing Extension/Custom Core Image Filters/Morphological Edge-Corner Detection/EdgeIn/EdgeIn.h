//
//  EdgeIn.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/11/15.
//
//

#import <CoreImage/CoreImage.h>

@interface EdgeIn : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end