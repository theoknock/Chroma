//
//  UIImage-Utils.h
//  Chroma
//
//  Created by James Alan Bush on 6/29/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#ifndef Chroma_UIImage_Utils_h
#define Chroma_UIImage_Utils_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark Bitmap Offsets
// ARGB Offset Helpers
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w);

@interface UIImage (Utils)
+ (UIImage *) imageWithBytes: (Byte *) bits withSize: (CGSize) size;
+ (NSData *) bytesFromImage: (UIImage *) image;
@property (nonatomic, readonly) NSData *bytes;
@end

#endif
