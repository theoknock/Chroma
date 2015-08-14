//
//  UIImage-Utils.m
//  Chroma
//
//  Created by James Alan Bush on 6/29/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "UIImage-Utils.h"

// ARGB Offset Helpers
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 0;}
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 1;}
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 2;}
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 3;}

@implementation UIImage (Utils)

void CGBitmapReleaseUsingFree(void* releaseInfo, void* data) {
    free(data);
}

// Build image from bytes
+ (UIImage *) imageWithBytes: (Byte *) bytes withSize: (CGSize) size
{
    // Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        free(bytes);
        return nil;
    }
    
    // Create the bitmap context
    //CGContextRef context = CGBitmapContextCreateWithData(bytes, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst, &CGBitmapReleaseUsingFree, nil);
    CGContextRef context = CGBitmapContextCreate (bytes, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free(bytes);
        CGColorSpaceRelease(colorSpace );
        return nil;
    }
    
    // Convert to image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    // Clean up
    CGColorSpaceRelease(colorSpace );
    free(CGBitmapContextGetData(context)); // frees bytes
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return image;
}


// Convert UIImage to byte array
+ (NSData *) bytesFromImage: (UIImage *) image
{
    CGSize size = image.size;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    void *bitmapData = malloc(size.width * size.height * 4);
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Error: Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //CGContextRef context = CGBitmapContextCreateWithData(bitmapData, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst, &CGBitmapReleaseUsingFree, nil);

    
    CGContextRef context = CGBitmapContextCreate (bitmapData, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace );
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bitmapData);
        return NULL;
    }
    
    CGRect rect = (CGRect){.size = size};
    CGContextDrawImage(context, rect, image.CGImage);
    Byte *byteData = CGBitmapContextGetData (context);
    CGContextRelease(context);
    
    NSData *data = [NSData dataWithBytes:byteData length:(size.width * size.height * 4)];
    free(bitmapData);
    
    return data;
}

- (NSData *) bytes
{
    return [UIImage bytesFromImage:self];
}
@end