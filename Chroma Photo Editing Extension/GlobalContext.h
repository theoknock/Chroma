//
//  GlobalContext.h
//  Chroma
//
//  Created by James Alan Bush on 7/4/15.
//  Copyright (c) 2015 James Alan Bush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

extern CIContext *ciContext;

@interface GlobalContext : NSObject
{
    CIContext *ciContext;
}

@property(nonatomic, retain) CIContext *ciContext;

+ (GlobalContext *)sharedSingleton;

+ (CIContext *)sharedContext;


@end
