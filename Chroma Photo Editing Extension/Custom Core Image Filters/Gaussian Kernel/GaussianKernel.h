//
//  GaussianKernel.h
//  Chroma
//
//  Created by James Alan Bush on 7/12/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface GaussianKernel : CIFilter
{
    CIImage *inputImage;
    NSNumber *inputRadius;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputRadius;

@end
