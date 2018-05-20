//
//  KSWebImage.m
//  HibikiPhotoViewerDemo
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

#import "HibikiImageManager.h"

@implementation HibikiImageManager

#pragma mark - HibikiImageManagerProtocol

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL *)imageURL
                 placeholder:(UIImage *)placeholder
                    progress:(HibikiImageManagerProgressBlock)progress
                  completion:(HibikiImageManagerCompletionBlock)completion
{
    YYWebImageProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            progress(receivedSize, expectedSize);
        }
    };
    
    YYWebImageCompletionBlock completionBlock = ^(UIImage *image,
                                                  NSURL *url,
                                                  YYWebImageFromType from,
                                                  YYWebImageStage stage,
                                                  NSError *error) {
        if (completion) {
            BOOL success = (stage == YYWebImageStageFinished) && !error;
            completion(image, url, success, error);
        }
    };
    
    [imageView yy_setImageWithURL:imageURL
                      placeholder:placeholder
                          options:kNilOptions
                         progress:progressBlock
                        transform:nil
                       completion:completionBlock];
}

- (void)cancelImageRequestForImageView:(UIImageView *)imageView
{
    [imageView yy_cancelCurrentImageRequest];
}

- (UIImage *)imageFromMemoryForURL:(NSURL *)url
{
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [manager.cache getImageForKey:key withType:YYImageCacheTypeMemory];
}

@end
