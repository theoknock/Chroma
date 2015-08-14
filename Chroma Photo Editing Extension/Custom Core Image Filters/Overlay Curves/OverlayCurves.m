//
//  H(S-V).m
//  Photo Filter
//
//  Created by James Alan Bush on 6/15/15.
//
//

#import "OverlayCurves.h"
#import "GlobalCIImage.h"
#import "GlobalContext.h"

@implementation OverlayCurves

@synthesize inputImage;
@synthesize inputCurve;
@synthesize inputMinContrastValue;
@synthesize inputMaxContrastValue;

+ (NSDictionary *)customAttributes
{
    return @{
             @"inputCurve" :
                 @{
                     kCIAttributeMin       : @0.0,
                     kCIAttributeMax       : @2.0,
                     kCIAttributeType      : kCIAttributeTypeScalar
                     },
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

- (CIKernel *)overlayCurvesKernel
{
    static CIKernel *kernelOverlayCurves = nil;
    
    NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"OverlayCurves")];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError     *error = nil;
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"OverlayCurvesKernel" ofType:@"cikernel"] encoding:encoding error:&error];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelOverlayCurves = [CIKernel kernelWithString:code];
    });
    
    return kernelOverlayCurves;
}

- (CIImage *)outputImage
{
    [GlobalCIImage sharedSingleton].ciImage = self.inputImage;
    
    NSNumber *inputHeight = [NSNumber numberWithFloat:[GlobalCIImage sharedSingleton].ciImage.extent.size.height];
    NSNumber *inputWidth  = [NSNumber numberWithFloat:[GlobalCIImage sharedSingleton].ciImage.extent.size.width];
    
    return [[self overlayCurvesKernel] applyWithExtent:[[GlobalCIImage sharedSingleton].ciImage extent] roiCallback:^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth([[GlobalCIImage sharedSingleton].ciImage extent]), CGRectGetHeight([[GlobalCIImage sharedSingleton].ciImage extent]));
    } arguments:@[[GlobalCIImage sharedSingleton].ciImage, self.inputCurve, self.inputMinContrastValue, self.inputMaxContrastValue, inputHeight, inputWidth]];
}

@end
