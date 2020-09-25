//
//  KSWebImageProtocol.h
//  HibikiPhotoViewerDemo
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

#import "HibikiImageManagerProtocol.h"

#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
#import "SDWebImage.h"
#endif

@interface HibikiImageManager : NSObject <HibikiImageManager>

@end
