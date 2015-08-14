//
//  Bilateral.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/25/15.
//
//

#import "Equalize.h"
#import "AppSingleton.h"
#import "GlobalCIImage.h"
#import "GlobalContext.h"
#import "UIImage-vImage.h"
#import "UIImage-Utils.h"

@implementation Equalize

@synthesize inputImage;
@synthesize equalizedImage;

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [CIImage imageWithCGImage:[[UIImage imageWithCGImage:[[GlobalContext sharedSingleton].ciContext createCGImage:[GlobalCIImage sharedSingleton].ciImage fromRect:[GlobalCIImage sharedSingleton].ciImage.extent]] equalize:TRUE stretchContrast:TRUE].CGImage];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

/*
- (CGContextRef)newARGBBitmapContext:(CGSize)sz
{
    size_t bitmapBytesPerRow = sz.width * 4;
    CGColorSpaceRef dRGB = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, sz.width, sz.height, 8, bitmapBytesPerRow, dRGB, kCGBitmapByteOrder32Host | kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(dRGB);
    
    return context;
}

- (vImage_Error) runVImageOperation:(vImage_Buffer*)input output:(vImage_Buffer*)output
{
    
}

void CGBitmapReleaseUsingFree(void* releaseInfo, void* data)
{
    free(data);
}

- (CIImage*)outputImage
{
    vImage_Buffer outBuffer = {0, 0, 0, 0];
        {
            CGContextRef cgContext = nil;
            {
                CGImageRef cgFromCi = nil;
                {
                    CIContext* context = [TRHelper getCIContext];
                    cgFromCi = [context createCGImageMoreSafely:self.inputImage fromRect:self.inputImage.extent];
                    [TRHelper doneWithCIContext:context];
                }
                
                cgContext = [self newARGBBitmapContext:self.inputImage.extent.size];
                CGContextDrawImage(cgContext, self.inputImage.extent, cgFromCi);
                CGImageRelease(cgFromCi);
            }
            
            vImage_buffer inBuffer = {0, 0, 0, 0};
            inBuffer.width    = CGBitmapContextGetWidth(cgContext);
            inBuffer.height   = CGBitmapContextGetHeight(cgContext);
            inBuffer.rowBytes = CGBitmapContextGetBytesPerRow(cgContext);
            inBuffer.data     = CGBitmapContextGetData(cgContext);
            
            size_t pixelBufferSize = inBuffer.rowBytes * inBuffer.height;
            void* pixelBuffer = malloc(pixelBufferSize + 16);
            if (!pixelBuffer)
                CGContextRelease(cgContext);
            
            outBuffer.width = inBuffer.width;
            outBuffer.height = inBuffer.height;
            outBuffer.rowBytes = inBuffer.rowBytes;
            outBuffer.data = pixelBuffer;
            
            vImage_Error error = [self runVImageOperation:&inBuffer output:&outBuffer];
            if (error != kvImageNoError)
                free(pixelBuffer);
            
            CGContextRelease(cgContext);
        }
        
        CGColorSpaceRef dRGB = CGColorSpaceCreateDeviceRGB();
        CGContextRef cgOutputCtx = CGBitmapContextCreateWithData(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, dRGB, kCGBitmapByteOrder32Host | kCGImageAlphaNoneSkipFirst, &CGBitmapReleaseUsingFree, nil);
        CGImageRef cgOutput= CGBitmapContextCreateImage(cgOutputCtx);
        CGColorSpaceRelease(dRGB);
        
        CIImage* [GlobalCIImage sharedSingleton].ciImage = [CIImage imageWithCGImage:cgOutput];

        CGImageRelease(cgOutput);
        CGContextRelease(cgOutputCtx);
        
        return [GlobalCIImage sharedSingleton].ciImage;
}

- (void)getCGImage
{
    CGImageRelease(outCGImage);
    CIContext *myContext;
    vImage_Buffer inBuffer, buffer;
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    if([EAGLContext currentContext] == myEAGLContext)
        [EAGLContext setCurrentContext:nil];
    myContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    cgImage = [myContext createCGImage:self.inputImage fromRect:self.inputImage.extent];

    vImage_CGImageFormat format = {
        .bitsPerComponent = (u_int32_t)CGImageGetBitsPerComponent(cgImage),
        .bitsPerPixel = (u_int32_t)CGImageGetBitsPerPixel(cgImage),
        .bitmapInfo = CGImageGetBitmapInfo(cgImage),
        .colorSpace = CGImageGetColorSpace(cgImage)
    };
    
    // Create memory buffer
    NSUInteger pixelsWide = (u_int32_t)CGImageGetWidth(cgImage);
    NSUInteger pixelsHigh = (u_int32_t)CGImageGetHeight(cgImage);
    NSUInteger rowBytes = pixelsWide * CGImageGetBytesPerRow(cgImage);
    if(rowBytes % 16)
        rowBytes = (rowBytes / 16 + 1) * 16;
    void *pixelBuffer = valloc(pixelsHigh * rowBytes);
    
    inBuffer.data = (void*)CGImageGetDataProvider(cgImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(cgImage);
    inBuffer.width = pixelsWide;
    inBuffer.height = pixelsHigh;

    buffer.data = pixelBuffer;
    buffer.rowBytes = rowBytes;
    buffer.width = pixelsWide;
    buffer.height = pixelsHigh;
    
    vImageBuffer_Init(&inBuffer, (u_int32_t)CGImageGetHeight(cgImage), (u_int32_t)CGImageGetWidth(cgImage), (u_int32_t)CGImageGetBitsPerPixel(cgImage), kvImageNoError);
    //buffer.data = CGImageGetDataProvider(cgImage);
    //vImageBuffer_InitWithCGImage( &buffer, &format, NULL, cgImage, kvImageNoFlags );
    
    vImageEqualization_ARGB8888(&inBuffer, &buffer, kvImageNoFlags);
    
    vImage_CGImageFormat format_cgi = {
        .bitsPerComponent = (u_int32_t)CGImageGetBitsPerComponent(cgImage),
        .bitsPerPixel = (u_int32_t)CGImageGetBitsPerPixel(cgImage),
        .bitmapInfo = CGImageGetBitmapInfo(cgImage),
        .colorSpace = CGImageGetColorSpace(cgImage)
    };
    CGImageRelease(cgImage);
    outCGImage = vImageCreateCGImageFromBuffer( &buffer, &format_cgi, NULL, NULL, kvImageNoFlags, kvImageNoError);
    //free((void*)&inBuffer);
}


- (UIImage *) imageWithBytes: (Byte *) bytes withSize: (CGSize) size
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
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    
    // Convert to image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    // Clean up
    CGColorSpaceRelease(colorSpace);
    free(CGBitmapContextGetData(context)); // frees bytes
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return image;
}

- (CIImage *)outputImage
{
    /*
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    CGImageRef cgImage;
    cgImage = [[GlobalContext sharedContext] createCGImage:[GlobalCIImage sharedSingleton].ciImage fromRect:[[GlobalCIImage sharedSingleton].ciImage extent]];
    
    vImage_CGImageFormat format_cgi = {
        .bitsPerComponent = (u_int32_t)CGImageGetBitsPerComponent(cgImage),
        .bitsPerPixel = (u_int32_t)CGImageGetBitsPerPixel(cgImage),
        .colorSpace = CGImageGetColorSpace(cgImage),
        .bitmapInfo = CGImageGetAlphaInfo(cgImage) | CGImageGetBitmapInfo(cgImage),
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault
    };

    CGRect rect = [[GlobalCIImage sharedSingleton].ciImage extent];
    rect.origin = CGPointZero;
    CGRect cropRectLeft = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    
        // Create memory buffer
        NSUInteger pixelsWide = (u_int32_t)CGImageGetWidth(cgImage);
        NSUInteger pixelsHigh = (u_int32_t)CGImageGetHeight(cgImage);
        NSUInteger rowBytes = sizeof(Byte) * [GlobalCIImage sharedSingleton].ciImage.extent.size.width * 4;
        if(rowBytes % 16)
            rowBytes = (rowBytes / 16 + 1) * 16;
        //void* pixelBuffer = valloc(pixelsHigh * rowBytes);
        Byte *pixelBuffer = (Byte *)malloc(rowBytes * pixelsHigh);
        
    [[GlobalContext sharedContext] render:[GlobalCIImage sharedSingleton].ciImage toBitmap:pixelBuffer rowBytes:CGImageGetBytesPerRow(cgImage) bounds:cropRectLeft format:kCIFormatBGRA8 colorSpace:CGImageGetColorSpace(cgImage)];
        
        vImage_Buffer inbuf, outbuf;
        inbuf.data = (void *)CGImageGetDataProvider(cgImage);
        inbuf.rowBytes = rowBytes;
        inbuf.width = pixelsWide;
        inbuf.height = pixelsHigh;
        outbuf.data = (void *) pixelBuffer;
        outbuf.rowBytes = rowBytes;
        outbuf.width = pixelsWide;
        outbuf.height = pixelsHigh;
        
        //vImageBuffer_Init( &buf, CGImageGetHeight(cgImage), CGImageGetWidth(cgImage), (u_int32_t)CGImageGetBitsPerPixel(cgImage), kvImageNoFlags);
        //self.inputImage = [CIImage imageWithCGImage:vImageCreateCGImageFromBuffer( &buf, &format_cgi, NULL, NULL, kvImageNoFlags, kvImageNoError)];
        //vImageBuffer_InitWithCGImage( &buf, &format, NULL, cgImage, kvImageNoError );
        
        vImageEqualization_ARGB8888(&inbuf, &outbuf, kvImageNoError);
        free(pixelBuffer);
    
        //[GlobalCIImage sharedSingleton].ciImage = [CIImage imageWithCGImage:vImageCreateCGImageFromBuffer( &outbuf, &format_cgi, NULL, NULL, kvImageNoFlags, kvImageNoError)];
        CGImageRelease(cgImage);
        UIImage *result = [[self imageWithBytes:outbuf withSize:[GlobalCIImage sharedSingleton].ciImage.extent.size];

    return result.CIImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[UIImage imageWithCIImage:[GlobalCIImage sharedSingleton].ciImage] equalize].CIImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
    
}

*/

@end
