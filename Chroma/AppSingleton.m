//
//  AppSingleton.m
//  Chroma
//
//  Created by James Alan Bush on 7/4/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "AppSingleton.h"

@implementation AppSingleton

+(CIContext *)globalContext
{
    static dispatch_once_t once;
    static CIContext *sharedContext;
    dispatch_once(&once, ^
                  {
                      EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
                      NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
                      if([EAGLContext currentContext] == myEAGLContext)
                          [EAGLContext setCurrentContext:nil];
                      sharedContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
                  });
    return sharedContext;
}

+(CIImage *)globalImage
{
    static dispatch_once_t once;
    static CIImage *sharedImage;
    dispatch_once(&once, ^
                  {
                      CIImage *result;
                      sharedImage = result;
                  });
    return sharedImage;
}

@end
