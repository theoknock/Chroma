//
//  Bilateral.h
//  Photo Filter
//
//  Created by James Alan Bush on 5/25/15.
//
//

#import <CoreImage/CoreImage.h>
#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Equalize : CIFilter
{
    CIImage *inputImage;
    UIImage *equalizedImage;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) UIImage *equalizedImage;

@end