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

@import UIKit;

typedef void (^HibikiImageManagerProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void (^HibikiImageManagerCompletionBlock)(UIImage * _Nullable image, NSURL * _Nullable url, BOOL success, NSError * _Nullable error);

@protocol HibikiImageManager <NSObject>

#pragma mark - Methods
- (void)setImageForImageView:(nullable UIImageView *)imageView
                     withURL:(nullable NSURL *)imageURL
                 placeholder:(nullable UIImage *)placeholder
                    progress:(nullable HibikiImageManagerProgressBlock)progress
                  completion:(nullable HibikiImageManagerCompletionBlock)completion;

- (void)cancelImageRequestForImageView:(nullable UIImageView *)imageView;

@end
