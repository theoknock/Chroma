//
//  OverlayHistogram.m
//  Photo Filter
//
//  Created by James Alan Bush on 6/22/15.
//
//

#import "OverlayHistogram.h"
#import "GlobalCIImage.h"

@implementation OverlayHistogram

@synthesize inputImage;

- (CIKernel *)overlayHistogramKernel
{
    static CIKernel *kernelOverlayHistogram = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"OverlayHistogram")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"OverlayHistogramKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelOverlayHistogram = [CIKernel kernelWithString:code];
    });
    
    return kernelOverlayHistogram;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    [GlobalCIImage sharedSingleton].ciImage = [[self overlayHistogramKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, [NSNumber numberWithFloat:[GlobalCIImage sharedSingleton].ciImage.extent.size.height]]];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
