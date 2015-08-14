//
//  ExposureGamma.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/24/15.
//
//

#import "ExposureGamma.h"
#import "GlobalCIImage.h"

@implementation ExposureGamma

@synthesize inputImage;

- (CIKernel *)exposureGammaKernel
{
    static CIKernel *kernelExposureGamma = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Chroma")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ExposureGammaKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelExposureGamma = [CIKernel kernelWithString:code];
    });
    
    return kernelExposureGamma;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"ContrastStretch" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[self exposureGammaKernel] applyWithExtent:self.inputImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight(self.inputImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
