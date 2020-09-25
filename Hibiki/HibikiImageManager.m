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
    [imageView sd_setImageWithURL:imageURL
                 placeholderImage:placeholder
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progress) {
            progress(receivedSize, expectedSize);
        }
    } completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completion) {
            BOOL success = !error;
            completion(image, imageURL, success, error);
        }
    }];
}

- (void)cancelImageRequestForImageView:(UIImageView *)imageView
{
    [imageView sd_cancelCurrentImageLoad];
}

@end
