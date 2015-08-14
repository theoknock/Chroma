//
//  AppSingleton.h
//  Chroma
//
//  Created by James Alan Bush on 7/4/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>

@interface AppSingleton : NSObject

+(CIContext *)globalContext;

+(CIImage *)globalImage;

@end
