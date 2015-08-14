//
//  H(S-V).m
//  Photo Filter
//
//  Created by James Alan Bush on 6/15/15.
//
//

#import "BushCurve.h"
#import "GlobalCIImage.h"
#import "GlobalContext.h"

@implementation BushCurve

@synthesize inputImage;
@synthesize inputMinContrastValue;
@synthesize inputMaxContrastValue;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputMinContrastValue" :
                 @{
                     kCIAttributeMin       : @0.1,
                     kCIAttributeMax       : @10.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
             
             @"inputMaxContrastValue" :
                 @{
                     kCIAttributeMin       : @0.1,
                     kCIAttributeMax       : @10.0,
                     kCIAttributeDefault   : @1.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     }
             };
}

- (CIKernel *)bushCurveKernel
{
    static CIKernel *kernelBushCurve = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"BushCurve")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"BushCurveKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelBushCurve = [CIKernel kernelWithString:code];
    });
    
    return kernelBushCurve;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    NSNumber *inputHeight = [NSNumber numberWithFloat:[GlobalCIImage sharedSingleton].ciImage.extent.size.height];
    NSNumber *inputWidth  = [NSNumber numberWithFloat:[GlobalCIImage sharedSingleton].ciImage.extent.size.width];

    return [[self bushCurveKernel] applyWithExtent:[[GlobalCIImage sharedSingleton].ciImage extent] roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([[GlobalCIImage sharedSingleton].ciImage extent]), CGRectGetHeight([[GlobalCIImage sharedSingleton].ciImage extent]));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, inputMinContrastValue, inputMaxContrastValue, inputHeight, inputWidth]];
 }

@end
