//
//  HibikiPhoto.h
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class HibikiPhoto;

@protocol HibikiPhotoDelegate<NSObject>

#pragma mark - Properties
- (void)photo:(HibikiPhoto *)photo didUpdateUrl:(NSURL *)url;
- (void)photo:(HibikiPhoto *)photo isLoadingFinished:(BOOL)finished;

@end

@interface HibikiPhoto : NSObject

#pragma mark - Properties
@property (nonatomic, strong, readwrite, nullable) UIView *sourceView;
@property (nonatomic, strong, readonly, nullable) UIImage *thumbImage;
@property (nonatomic, strong, readonly, nullable) UIImage *image;
@property (nonatomic, strong, readwrite, nullable) NSURL *imageUrl;
@property (nonatomic, assign, readwrite) BOOL finished;
@property (nonatomic, weak, readwrite) id<HibikiPhotoDelegate> delegate;

#pragma mark - Methods
- (instancetype)initWithSourceView:(nullable UIView *)view thumbImage:(nullable UIImage *)image imageUrl:(nullable NSURL *)url;
- (instancetype)initWithSourceView:(nullable UIImageView * )view imageUrl:(nullable NSURL *)url;
- (instancetype)initWithSourceView:(nullable UIImageView *)view image:(nullable UIImage *)image;

+ (instancetype)itemWithSourceView:(nullable UIView *)view thumbImage:(nullable UIImage *)image imageUrl:(nullable NSURL *)url;
+ (instancetype)itemWithSourceView:(nullable UIImageView *)view imageUrl:(nullable NSURL *)url;
+ (instancetype)itemWithSourceView:(nullable UIImageView *)view image:(nullable UIImage *)image;

@end

NS_ASSUME_NONNULL_END
