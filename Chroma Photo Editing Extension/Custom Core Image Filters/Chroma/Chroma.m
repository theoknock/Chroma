//
//  Chroma.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "Chroma.h"
#import "GlobalCIImage.h"

@implementation Chroma

@synthesize inputImage;

- (CIKernel *)chromaKernel
{
    static CIKernel *kernelChroma = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Chroma")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ChromaKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelChroma = [CIKernel kernelWithString:code];
    });
    
    return kernelChroma;
}

- (CIImage *)outputImage
{
    /*
    [GlobalCIImage sharedSingleton].ciImage  = [CIFilter filterWithName:@"CILinearToSRGBToneCurve" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
        
    [GlobalCIImage sharedSingleton].ciImage = [[self chromaKernel] applyWithExtent:self.inputImage.extent roiCallback:^CGRect(int index, CGRect rect) {
            return CGRectMake(0, 0, CGRectGetWidth(self.inputImage.extent), CGRectGetHeight(self.inputImage.extent));
        } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.25]]];
     
    CGRect inputExtent = [self.inputImage extent];
    CIVector *extent = [CIVector vectorWithX:inputExtent.origin.x
                                           Y:inputExtent.origin.y
                                           Z:inputExtent.size.width
                                           W:inputExtent.size.height];
    CIImage* inputAverage = [CIFilter filterWithName:@"CIAreaMinimum" keysAndValues:@"inputImage", self.inputImage, @"inputExtent", extent, nil].outputImage;
    
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    CIContext *myContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    
    size_t rowBytes = 32 ; // ARGB has 4 components
    uint8_t byteBuffer[rowBytes]; // Buffer to render into
    
    [myContext render:inputAverage toBitmap:byteBuffer rowBytes:rowBytes bounds:[inputAverage extent] format:kCIFormatRGBA8 colorSpace:nil];
    
    const uint8_t* pixel = &byteBuffer[0];
    float red   = pixel[1] / 255.0;
    float green = pixel[2] / 255.0;
    float blue  = pixel[3] / 255.0;
    //NSLog(@"%f, %f, %f\n", red, green, blue);
    */
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    return [[self chromaKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];

    /*[GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CISubtractBlendMode" keysAndValues:@"inputImage", [GlobalCIImage sharedSingleton].ciImage, @"inputBackgroundImage", self.inputImage, nil].outputImage;*/
}

@end
