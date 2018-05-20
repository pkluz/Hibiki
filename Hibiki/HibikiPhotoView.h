//
//  HibikiPhotoView.h
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

extern const CGFloat kHibikiPhotoViewPadding;

@class YYAnimatedImageView;
@class HibikiProgressLayer;
@class HibikiPhoto;

@protocol HibikiImageManager;

@interface HibikiPhotoView : UIScrollView

#pragma mark - Properties
@property (nonatomic, strong, readonly) YYAnimatedImageView *imageView;
@property (nonatomic, strong, readonly) HibikiProgressLayer *progressLayer;
@property (nonatomic, strong, readonly) HibikiPhoto *item;

#pragma mark - Methods
- (instancetype)initWithFrame:(CGRect)frame imageManager:(id<HibikiImageManager>)imageManager;
- (void)setItem:(HibikiPhoto *)item determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

@end

NS_ASSUME_NONNULL_END
