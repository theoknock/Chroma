//
//  RobertsKernel.m
//  Photo Filter
//
//  Created by James Alan Bush on 5/22/15.
//
//

#import "RobertsKernel.h"

@implementation RobertsKernel

@synthesize inputImage;

- (CIKernel *)robertsKernel
{
    static CIKernel *kernelRoberts = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"RobertsKernel")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"RobertsKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelRoberts = [CIKernel kernelWithString:code];
    });
    
    return kernelRoberts;
}

- (CIImage *)outputImage
{
    return [[self robertsKernel] applyWithExtent:self.inputImage.extent roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth(self.inputImage.extent), CGRectGetHeight(self.inputImage.extent));
    } arguments:@[self.inputImage]];
}

@end
