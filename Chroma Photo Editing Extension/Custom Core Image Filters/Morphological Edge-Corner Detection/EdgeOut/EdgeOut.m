//
//  EdgeOut.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/11/15.
//
//

#import "EdgeOut.h"
#import "GlobalCIImage.h"

@implementation EdgeOut

@synthesize inputImage;

- (CIKernel *)dilateKernel
{
    static CIKernel *kernelDilate = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Dilate")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"DilateKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelDilate = [CIKernel kernelWithString:code];
    });
    
    return kernelDilate;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage; //[CIFilter filterWithName:@"ContrastStretch" keysAndValues:kCIInputImageKey, self.inputImage, nil].outputImage;
    
    for (int i = 0; i < 1; i++) {
        [GlobalCIImage sharedSingleton].ciImage = [[self dilateKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
            return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
        } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    }
    
    [GlobalCIImage sharedSingleton].ciImage = [CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:kCIInputImageKey, self.inputImage, kCIInputBackgroundImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
