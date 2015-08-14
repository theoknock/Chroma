//
//  FourDirectionalMinMax.h
//  Chroma
//
//  Created by James Alan Bush on 7/5/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface FourDirectionalMinMax : CIFilter
{
    CIImage *inputImage;
}

@property (retain, nonatomic) CIImage *inputImage;

@end