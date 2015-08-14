//
//  UIImage-vImage.m
//  Chroma
//
//  Created by James Alan Bush on 6/29/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "UIImage-vImage.h"
#import "UIImage-Utils.h"

@implementation UIImage (vImage)
- (vImage_Buffer) baseBuffer
{
    vImage_Buffer buf;
    buf.height = self.size.height;
    buf.width = self.size.width;
    buf.rowBytes = sizeof(Byte) * self.size.width * 4; // ARGB
    return buf;
}

- (vImage_Buffer) buffer
{
    vImage_Buffer buf = [self baseBuffer];
    buf.data = (void *)self.bytes.bytes;
    return buf;
}

- (UIImage *) vImageRotate: (CGFloat) theta
{
    vImage_Buffer inBuffer = [self buffer];
    vImage_Buffer outBuffer = [self baseBuffer];
    Byte *outData = (Byte *)malloc(outBuffer.rowBytes * outBuffer.height);
    outBuffer.data = (void *) outData;
    uint8_t backColor[4] = {0xFF, 0, 0, 0};
    
    vImage_Error error = vImageRotate_ARGB8888(&inBuffer, &outBuffer, NULL, theta, backColor, 0);
    
    if (error)
    {
        NSLog(@"Error rotating image: %ld", error);
        free(outData);
        return self;
    }
    
    return [UIImage imageWithBytes:outData withSize:self.size];
}

int32_t getDivisor(NSData *kernel)
{
    const int16_t *matrix = (const int16_t *)kernel.bytes;
    unsigned long count = kernel.length / sizeof(const int16_t);
    
    // Sum up the kernel elements
    int32_t sum = 0;
    for (CFIndex i = 0; i < count; i++)
    sum += matrix[i];
    if (sum != 0) return sum;
    return 1;
}


- (UIImage *) vImageConvolve: (NSData *) kernel
{
    vImage_Buffer inBuffer = [self buffer];
    vImage_Buffer outBuffer = [self baseBuffer];
    Byte *outData = (Byte *)malloc(outBuffer.rowBytes * outBuffer.height);
    outBuffer.data = (void *) outData;
    uint8_t backColor[4] = {0xFF, 0, 0, 0};
    
    const int16_t *matrix = (const int16_t *)kernel.bytes;
    uint32_t matrixSide = sqrt(kernel.length / sizeof(int16_t));
    int32_t divisor = getDivisor(kernel);
    vImage_Error error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, matrix, matrixSide, matrixSide, divisor, backColor, kCGImageAlphaPremultipliedFirst);
    if (error)
    {
        NSLog(@"Error convolving image: %ld", error);
        free(outData);
        return self;
    }
    
    return [UIImage imageWithBytes:outData withSize:self.size];
}

- (UIImage *) equalize: (bool) switchOnEqualize stretchContrast: (bool) switchOnContrast
{
    if (switchOnEqualize || switchOnContrast)
    {
        vImage_Buffer inBuffer = [self buffer];
        vImage_Buffer outBuffer = [self baseBuffer];
        Byte *outData = (Byte *)malloc(outBuffer.rowBytes * outBuffer.height);
        outBuffer.data = (void *) outData;

        if (switchOnEqualize)
        {
            vImage_Error errorEqualize = vImageEqualization_ARGB8888(&inBuffer, &outBuffer, kvImageNoFlags);
            if (errorEqualize)
            {
                NSLog(@"Error convolving image: %ld", errorEqualize);
                free(outData);
                return self;
            }
        }
        
        if (switchOnContrast)
        {
            vImage_Error errorStretch = vImageContrastStretch_ARGB8888(&inBuffer, &outBuffer, kvImageNoFlags);
            if (errorStretch)
            {
                NSLog(@"Error convolving image: %ld", errorStretch);
                free(outData);
                return self;
            }
        }
        
        return [UIImage imageWithBytes:outData withSize:self.size];
    } else {
        return self;
    }
}

- (UIImage *) stretchContrast: (bool) switchOn
{
    
    if (switchOn)
    {
    vImage_Buffer inBuffer = [self buffer];
    vImage_Buffer outBuffer = [self baseBuffer];
    Byte *outData = (Byte *)malloc(outBuffer.rowBytes * outBuffer.height);
    outBuffer.data = (void *) outData;
    
    vImage_Error error = vImageContrastStretch_ARGB8888(&inBuffer, &outBuffer, kvImageNoFlags);
    if (error)
    {
        NSLog(@"Error convolving image: %ld", error);
        free(outData);
        return self;
    }
        /*q Temp histogram calc code
        vImagePixelCount				histogramA[256];
        vImagePixelCount				histogramR[256];
        vImagePixelCount				histogramG[256];
        vImagePixelCount				histogramB[256];
        vImagePixelCount*				histograms[4];
        
        histograms[0] = histogramA;
        histograms[1] = histogramR;
        histograms[2] = histogramG;
        histograms[3] = histogramB;
        vImage_Error errorH = vImageHistogramCalculation_ARGB8888(&inBuffer, histograms, 0);
        if (errorH)
        {
            NSLog(@"Error convolving image: %ld", errorH);
            free(outData);
            return self;
        }
        */
    
    return [UIImage imageWithBytes:outData withSize:self.size];
    } else {
        return self;
    }
}

#pragma mark - Averaging
- (UIImage *) blur: (NSInteger) radius
{
    unsigned long side = radius * 2 + 1;
    long memsize = sizeof(int16_t) * side * side;
    
    int16_t *matrix = malloc(memsize);
    for (CFIndex i = 0; i < (side * side); i++)
    matrix[i] = 1;
    
    NSData *matrixData = [NSData dataWithBytes:matrix length:memsize];
    free(matrix);
    
    return [self vImageConvolve:matrixData];
}

- (UIImage *) blur3
{
    return [self blur:1];
}

- (UIImage *) blur5
{
    return [self blur:2];
}

#pragma mark - Convolution

- (UIImage *) convolve: (const int16_t *) kernel side: (NSInteger) side
{
    long memsize = sizeof(int16_t) * side * side;
    NSData *matrixData = [NSData dataWithBytes:kernel length:memsize];
    return [self vImageConvolve:matrixData];
}

- (UIImage *) emboss
{
    static const int16_t kernel[] = {
        -2, -1,  0,
        -1,  1,  1,
        0,  1,  2};
    return [self convolve:kernel side:3];
}

- (UIImage *) sharpen
{
    static const int16_t kernel[] = {
        0,  -1,   0,
        -1,  8,  -1,
        0,  -1,   0
    };
    return [self convolve:kernel side:3];
}

- (UIImage *) gauss5
{
    static const int16_t kernel[] = {
        1,  4,  6,  4, 1,
        4, 16, 24, 16, 4,
        6, 24, 36, 24, 6,
        4, 16, 24, 16, 4,
        1,  4,  6,  4, 1
    };
    return [self convolve:kernel side:5];
}
@end