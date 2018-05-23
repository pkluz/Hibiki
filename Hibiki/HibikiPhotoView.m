//
//  HibikiPhotoView.m
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

#import "HibikiPhotoView.h"
#import "HibikiPhoto.h"
#import "HibikiProgressLayer.h"
#import "HibikiImageManagerProtocol.h"

#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYWebImage.h>
#else
#import "YYWebImage.h"
#endif

const CGFloat kHibikiPhotoViewPadding = 10;
const CGFloat kHibikiPhotoViewMaxScale = 3;

@interface HibikiPhotoView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate, HibikiPhotoDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readwrite) YYAnimatedImageView *imageView;
@property (nonatomic, strong, readwrite) HibikiProgressLayer *progressLayer;
@property (nonatomic, strong, readwrite) HibikiPhoto *item;
@property (nonatomic, strong, readwrite) id<HibikiImageManager> imageManager;
@property (nonatomic, assign, readwrite) BOOL loadDeterminate;

@end

@implementation HibikiPhotoView

#pragma mark - HibikiPhotoView

- (instancetype)initWithFrame:(CGRect)frame imageManager:(id<HibikiImageManager>)imageManager
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.bouncesZoom = YES;
        self.maximumZoomScale = kHibikiPhotoViewMaxScale;
        self.multipleTouchEnabled = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.backgroundColor = [UIColor darkGrayColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        [self resizeImageView];
        
        _progressLayer = [[HibikiProgressLayer alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _progressLayer.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        _progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
        
        _imageManager = imageManager;
    }
    
    return self;
}

- (void)setItem:(HibikiPhoto *)item determinate:(BOOL)determinate
{
    item.delegate = self;
    _loadDeterminate = determinate;
    _item = item;
    [_imageManager cancelImageRequestForImageView:_imageView];
    if (item) {
        if (item.image) {
            _imageView.image = item.image;
            _item.finished = YES;
            [_progressLayer stopSpinning];
            _progressLayer.hidden = YES;
            [self resizeImageView];
            return;
        }
        __weak typeof(self) wself = self;
        HibikiImageManagerProgressBlock progressBlock = nil;
        if (_loadDeterminate) {
            progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
                __strong typeof(wself) sself = wself;
                double progress = (double)receivedSize / expectedSize;
                sself.progressLayer.hidden = NO;
                sself.progressLayer.strokeEnd = MAX(progress, 0.01);
            };
        } else {
            [_progressLayer startSpinning];
        }
        _progressLayer.hidden = NO;
        
        _imageView.image = item.thumbImage;
        [_imageManager setImageForImageView:_imageView
                                    withURL:item.imageUrl
                                placeholder:item.thumbImage
                                   progress:progressBlock
                                 completion:^(UIImage *image, NSURL *url, BOOL finished, NSError *error) {
                                     __strong typeof(wself) sself = wself;
                                     if (finished) {
                                         [sself resizeImageView];
                                     }
                                     [sself.progressLayer stopSpinning];
                                     sself.progressLayer.hidden = YES;
                                     sself.item.finished = YES;
                                 }];
    } else {
        [_progressLayer stopSpinning];
        _progressLayer.hidden = YES;
        _imageView.image = nil;
    }
    [self resizeImageView];
}

- (void)resizeImageView
{
    if (_imageView.image) {
        CGSize imageSize = _imageView.image.size;
        CGFloat width = _imageView.frame.size.width;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        _imageView.frame = rect;
        
        // If image is very tall, show top content.
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
        // If image is very wide, make sure user can zoom to fullscreen.
        if (width / height > 2) {
            self.maximumZoomScale = self.bounds.size.height / height;
        }
    } else {
        CGFloat width = self.frame.size.width - 2 * kHibikiPhotoViewPadding;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    
    self.contentSize = _imageView.frame.size;
}

- (void)cancelCurrentImageLoad
{
    [_imageManager cancelImageRequestForImageView:_imageView];
    [_progressLayer stopSpinning];
}

- (BOOL)isScrollViewOnTopOrBottom
{
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    if (translation.y > 0 && self.contentOffset.y <= 0) {
        return YES;
    }
    CGFloat maxOffsetY = floor(self.contentSize.height - self.bounds.size.height);
    if (translation.y < 0 && self.contentOffset.y >= maxOffsetY) {
        return YES;
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
            if ([self isScrollViewOnTopOrBottom]) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - HibikiPhotoDelegate

- (void)photo:(HibikiPhoto *)photo isLoadingFinished:(BOOL)finished
{
    // NOOP
}

- (void)photo:(HibikiPhoto *)photo didUpdateUrl:(NSURL *)url
{
    [self setItem:photo determinate:_loadDeterminate];
}

@end
