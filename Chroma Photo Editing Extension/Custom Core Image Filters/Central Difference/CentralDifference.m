//
//  CentralDifference.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "CentralDifference.h"
#import "GlobalCIImage.h"

@implementation CentralDifference

@synthesize inputImage;

- (CIKernel *)centralDifferenceKernel
{
    static CIKernel *kernelCentralDifference = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"CentralDifference")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"CentralDifferenceKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelCentralDifference = [CIKernel kernelWithString:code];
    });
    
    return kernelCentralDifference;
}
- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    return [[self centralDifferenceKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
}

@end
