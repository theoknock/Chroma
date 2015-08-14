//
//  CV.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "CV.h"
#import "GlobalCIImage.h"

@implementation CV

@synthesize inputImage;

- (CIKernel *)cvKernel
{
    static CIKernel *kernelCV = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"CV")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"CVKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelCV = [CIKernel kernelWithString:code];
    });
    
    return kernelCV;
}

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

- (CIKernel *)erodeKernel
{
    static CIKernel *kernelErode = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Erode")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ErodeKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelErode = [CIKernel kernelWithString:code];
    });
    
    return kernelErode;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self cvKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
