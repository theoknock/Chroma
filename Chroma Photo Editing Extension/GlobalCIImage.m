//
//  GlobalCIImage.m
//  Chroma
//
//  Created by James Alan Bush on 7/12/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import "GlobalCIImage.h"

CIImage *ciImage;

@implementation GlobalCIImage

@synthesize ciImage;

static GlobalCIImage *shared = NULL;

- (id)init
{
    if ( self = [super init] )
    {
        static dispatch_once_t once;
        dispatch_once(&once, ^
                      {
                          CIImage *result;
                          self.ciImage = result;
                      });
    }
    return self;
    
}

+ (GlobalCIImage *)sharedSingleton
{
    @synchronized(shared)
    {
        if ( !shared || shared == NULL )
        {
            shared = [[GlobalCIImage alloc] init];
        }
        
        return shared;
    }
}

+(CIImage *)sharedCIImage
{
    return ciImage;
}

@end

