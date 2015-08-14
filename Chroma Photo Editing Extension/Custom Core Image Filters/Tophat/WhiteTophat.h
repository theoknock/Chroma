//
//  WhiteTophat.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/10/15.
//
//

#import <CoreImage/CoreImage.h>

@interface WhiteTophat : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end