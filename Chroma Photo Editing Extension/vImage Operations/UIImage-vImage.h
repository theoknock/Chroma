//
//  UIImage-vImage.h
//  Chroma
//
//  Created by James Alan Bush on 6/29/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#ifndef Chroma_UIImage_vImage_h
#define Chroma_UIImage_vImage_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (vImage)
- (UIImage *) vImageRotate: (CGFloat) theta;
- (UIImage *) vImageConvolve: (NSData *) kernel;
@property (nonatomic, readonly) vImage_Buffer buffer;

- (UIImage *) blur: (NSInteger) radius;
- (UIImage *) blur3;
- (UIImage *) blur5;

- (UIImage *) convolve: (const int16_t *) kernel side: (NSInteger) side;
- (UIImage *) emboss;
- (UIImage *) sharpen;
- (UIImage *) gauss5;
- (UIImage *) equalize: (bool) switchOn stretchContrast: (bool) switchOn;
- (UIImage *) stretchContrast: (bool) switchOn;
@end

#endif
