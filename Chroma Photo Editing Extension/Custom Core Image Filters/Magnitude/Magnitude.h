//
//  Magnitude.h
//  Chroma
//
//  Created by James Alan Bush on 8/8/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface Magnitude : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end
