//
//  Dissimilarity.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/23/15.
//
//

#import "Dissimilarity.h"
#import "GlobalCIImage.h"
#import "GlobalContext.h"

@implementation Dissimilarity

@synthesize inputImage;

- (CIKernel *)dissimilarityKernel
{
    static CIKernel *kernelDissimilarity = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"Dissimilarity")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"DissimilarityKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelDissimilarity = [CIKernel kernelWithString:code];
    });
    
    return kernelDissimilarity;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    return [[self dissimilarityKernel] applyWithExtent:[GlobalCIImage sharedSingleton].ciImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([GlobalCIImage sharedSingleton].ciImage.extent), CGRectGetHeight([GlobalCIImage sharedSingleton].ciImage.extent));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage]];
    
    // return [CIFilter filterWithName:@"StretchContrastAverage" keysAndValues:kCIInputImageKey, [GlobalCIImage sharedSingleton].ciImage, nil].outputImage;
}

@end
