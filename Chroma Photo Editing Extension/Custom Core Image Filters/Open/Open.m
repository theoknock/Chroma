//
//  Opening.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "Open.h"
#import "GlobalCIImage.h"

@implementation Open

@synthesize inputImage;

- (CIKernel *)offsetErosionKernel
{
    static CIKernel *kernelOffsetErosion = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"OffsetErosionKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"OffsetErosionKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelOffsetErosion = [CIKernel kernelWithString:code];
    });
    
    return kernelOffsetErosion;
}

- (CIKernel *)offsetDilationKernel
{
    static CIKernel *kernelOffsetDilation = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"OffsetDilationKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"OffsetDilationKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelOffsetDilation = [CIKernel kernelWithString:code];
    });
    
    return kernelOffsetDilation;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage; //[CIFilter filterWithName:@"ContrastStretch" keysAndValues:kCIInputImageKey, self.inputImage, nil].outputImage;
    
    [GlobalCIImage sharedSingleton].ciImage = [[self offsetErosionKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
            return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
        } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    [GlobalCIImage sharedSingleton].ciImage = [[self offsetDilationKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    return [GlobalCIImage sharedSingleton].ciImage;
}

@end
