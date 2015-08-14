//
//  LocalContrastStretch.h
//  Photo Filter
//
//  Created by James Alan Bush on 6/5/15.
//
//

#import <CoreImage/CoreImage.h>

@interface LocalContrastStretch : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end
