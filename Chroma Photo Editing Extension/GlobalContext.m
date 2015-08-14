//
//  GlobalContext.m
//  Chroma
//
//  Created by James Alan Bush on 7/4/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import "GlobalContext.h"

CIContext *ciContext;

@implementation GlobalContext

@synthesize ciContext;

static GlobalContext *shared = NULL;

- (id)init
{
    if ( self = [super init] )
    {
        static dispatch_once_t once;
        dispatch_once(&once, ^
                      {
                          EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
                          NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
                          if([EAGLContext currentContext] == myEAGLContext)
                              [EAGLContext setCurrentContext:nil];
                          self.ciContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];

                      });
    }
    return self;
    
}

+ (GlobalContext *)sharedSingleton
{
    @synchronized(shared)
    {
        if ( !shared || shared == NULL )
        {
            shared = [[GlobalContext alloc] init];
        }
        
        return shared;
    }
}

+(CIContext *)sharedContext
{ 
    return ciContext;
}

@end

