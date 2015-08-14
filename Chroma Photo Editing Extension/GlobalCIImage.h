//
//  GlobalCIImage.h
//  Chroma
//
//  Created by James Alan Bush on 7/12/15.
//  Copyright © 2015 James Alan Bush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

extern CIImage *ciImage;

@interface GlobalCIImage : NSObject
{
    CIImage *ciImage;
}

@property(nonatomic, retain) CIImage *ciImage;

+ (GlobalCIImage *)sharedSingleton;

+ (CIImage *)sharedCIImage;


@end
