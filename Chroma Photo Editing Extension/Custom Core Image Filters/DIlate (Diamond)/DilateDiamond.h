//
//  DilateDiamond.h
//  Chroma
//
//  Created by James Alan Bush on 6/26/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface DilateDiamond : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputRadius;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputRadius;

@end