//
//  HibikiPhotoViewer.m
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

#import "HibikiPhotoViewer.h"
#import "HibikiProgressLayer.h"
#import "HibikiPhotoView.h"

#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
#import "SDWebImage.h"
#endif

static const NSTimeInterval kAnimationDuration = 0.3;
static const NSTimeInterval kSpringAnimationDuration = 0.5;
static Class imageManagerClass = nil;

@interface HibikiPhotoViewer () <UIScrollViewDelegate, UIViewControllerTransitioningDelegate, CAAnimationDelegate> {
    CGPoint _startLocation;
}

#pragma mark - Properties
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) NSMutableArray *photoItems;
@property (nonatomic, strong, readwrite) NSMutableSet *reusableItemViews;
@property (nonatomic, strong, readwrite) NSMutableArray *visibleItemViews;
@property (nonatomic, assign, readwrite) NSUInteger currentPage;
@property (nonatomic, strong, readwrite) UIImageView *backgroundView;
@property (nonatomic, assign, readwrite) BOOL presented;
@property (nonatomic, strong, readwrite) id<HibikiImageManager> imageManager;

@end

@implementation HibikiPhotoViewer

#pragma mark - NSObject

- (instancetype)init
{
    NSAssert(NO, @"Use initWithMediaItems: instead.");
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.alpha = 0;
    [self.view addSubview:_backgroundView];
    
    CGRect rect = self.view.bounds;
    rect.origin.x -= kHibikiPhotoViewPadding;
    rect.size.width += 2 * kHibikiPhotoViewPadding;
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    CGSize contentSize = CGSizeMake(rect.size.width * self.photoCount, rect.size.height);
    _scrollView.contentSize = contentSize;
    
    [self addGestureRecognizer];
    
    CGPoint contentOffset = CGPointMake(_scrollView.frame.size.width*_currentPage, 0);
    [_scrollView setContentOffset:contentOffset animated:NO];
    if (contentOffset.x == 0) {
        [self scrollViewDidScroll:_scrollView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    HibikiPhoto *item = [self photoAtIndex:_currentPage];
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    
    photoView.imageView.image = item.thumbImage;
    [photoView resizeImageView];
    
    CGRect endRect = photoView.imageView.frame;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    photoView.imageView.frame = sourceRect;
    
    if (_backgroundStyle == HibikiPhotoViewerBackgroundStyleBlur) {
        [self blurBackgroundWithImage:[self screenshot] animated:NO];
    } else if (_backgroundStyle == HibikiPhotoViewerBackgroundStyleBlurPhoto) {
        [self blurBackgroundWithImage:item.thumbImage animated:NO];
    }
    if (_bounces) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.frame = endRect;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configPhotoView:photoView withItem:item];
            _presented = YES;
            [self setStatusBarHidden:YES];
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.frame = endRect;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configPhotoView:photoView withItem:item];
            _presented = YES;
            [self setStatusBarHidden:YES];
        }];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - HibikiPhotoViewer

+ (void)setImageManagerClass:(Class<HibikiImageManager>)cls
{
    imageManagerClass = cls;
}

+ (instancetype)browserWithPhotoItems:(NSArray<HibikiPhoto *> *)photoItems
                        selectedIndex:(NSUInteger)selectedIndex
{
    HibikiPhotoViewer *browser = [[HibikiPhotoViewer alloc] initWithPhotoItems:photoItems
                                                                 selectedIndex:selectedIndex];
    return browser;
}

- (instancetype)initWithPhotoItems:(NSArray<HibikiPhoto *> *)photoItems
                     selectedIndex:(NSUInteger)selectedIndex
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        _photoItems = [NSMutableArray arrayWithArray:photoItems];
        _currentPage = selectedIndex;
        
        _dismissalStyle = HibikiPhotoViewerInteractiveDismissalStyleRotation;
        _backgroundStyle = HibikiPhotoViewerBackgroundStyleBlurPhoto;
        _loadingStyle = HibikiPhotoViewerImageLoadingStyleIndeterminate;
        
        _reusableItemViews = [[NSMutableSet alloc] init];
        _visibleItemViews = [[NSMutableArray alloc] init];
        _imageManager = [[HibikiImageManager alloc] init];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<HibikiPhotoViewerDelegate>)delegate
                   selectedIndex:(NSUInteger)selectedIndex
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        _photoItems = [NSMutableArray array];
        _delegate = delegate;
        _currentPage = selectedIndex;
        
        _dismissalStyle = HibikiPhotoViewerInteractiveDismissalStyleRotation;
        _backgroundStyle = HibikiPhotoViewerBackgroundStyleBlurPhoto;
        _loadingStyle = HibikiPhotoViewerImageLoadingStyleIndeterminate;
        
        _reusableItemViews = [[NSMutableSet alloc] init];
        _visibleItemViews = [[NSMutableArray alloc] init];
        _imageManager = [[HibikiImageManager alloc] init];
    }
    return self;
}

- (void)showFromViewController:(UIViewController *)vc
{
    [vc presentViewController:self animated:NO completion:nil];
}

- (void)setStatusBarHidden:(BOOL)hidden
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (hidden) {
        window.windowLevel = UIWindowLevelStatusBar + 1;
    } else {
        window.windowLevel = UIWindowLevelNormal;
    }
}

- (HibikiPhotoView *)photoViewForPage:(NSUInteger)page
{
    for (HibikiPhotoView *photoView in _visibleItemViews) {
        if (photoView.tag == page) {
            return photoView;
        }
    }
    return nil;
}

- (HibikiPhotoView *)dequeueReusableItemView
{
    HibikiPhotoView *photoView = [_reusableItemViews anyObject];
    if (photoView == nil) {
        photoView = [[HibikiPhotoView alloc] initWithFrame:_scrollView.bounds imageManager:_imageManager];
    } else {
        [_reusableItemViews removeObject:photoView];
    }
    photoView.tag = -1;
    return photoView;
}

- (void)updateReusableItemViews
{
    NSMutableArray *itemsForRemove = @[].mutableCopy;
    for (HibikiPhotoView *photoView in _visibleItemViews) {
        if (photoView.frame.origin.x + photoView.frame.size.width < _scrollView.contentOffset.x - _scrollView.frame.size.width ||
            photoView.frame.origin.x > _scrollView.contentOffset.x + 2 * _scrollView.frame.size.width) {
            [photoView removeFromSuperview];
            [self configPhotoView:photoView withItem:nil];
            [itemsForRemove addObject:photoView];
            [_reusableItemViews addObject:photoView];
        }
    }
    [_visibleItemViews removeObjectsInArray:itemsForRemove];
}

- (void)configItemViews
{
    NSInteger page = _scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5;
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i < 0 || i >= self.photoCount) {
            continue;
        }
        HibikiPhotoView *photoView = [self photoViewForPage:i];
        if (photoView == nil) {
            photoView = [self dequeueReusableItemView];
            CGRect rect = _scrollView.bounds;
            rect.origin.x = i * _scrollView.bounds.size.width;
            photoView.frame = rect;
            photoView.tag = i;
            [_scrollView addSubview:photoView];
            [_visibleItemViews addObject:photoView];
        }
        if (photoView.item == nil && _presented) {
            HibikiPhoto *item = [self photoAtIndex:i];
            [self configPhotoView:photoView withItem:item];
        }
    }
    
    if (page != _currentPage && _presented && (page >= 0 && page < self.photoCount)) {
        HibikiPhoto *item = [self photoAtIndex:page];
        if (_backgroundStyle == HibikiPhotoViewerBackgroundStyleBlurPhoto) {
            [self blurBackgroundWithImage:item.thumbImage animated:YES];
        }
        _currentPage = page;
        if (_delegate && [_delegate respondsToSelector:@selector(photoViewer:didSelectItem:atIndex:)]) {
            [_delegate photoViewer:self didSelectItem:item atIndex:page];
        }
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    for (HibikiPhotoView *photoView in _visibleItemViews) {
        [photoView cancelCurrentImageLoad];
    }
    
    HibikiPhoto *item = [self photoAtIndex:_currentPage];
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            item.sourceView.alpha = 1;
        }];
    } else {
        item.sourceView.alpha = 1;
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)performRotationWithPan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat angle = 0;
            if (_startLocation.x < self.view.frame.size.width/2) {
                angle = -(M_PI / 2) * (point.y / self.view.frame.size.height);
            } else {
                angle = (M_PI / 2) * (point.y / self.view.frame.size.height);
            }
            CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(0, point.y);
            CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
            photoView.imageView.transform = transform;
            
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showRotationCompletionAnimationFromPoint:point];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performScaleWithPan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;
            percent = MAX(percent, 0);
            double s = MAX(percent, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x/s, point.y/s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            photoView.imageView.transform = CGAffineTransformConcat(translation, scale);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 100 || fabs(velocity.y) > 500) {
                [self showDismissalAnimation];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performSlideWithPan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            photoView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showSlideCompletionAnimationFromPoint:point];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (UIImage *)screenshot
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, [UIScreen mainScreen].scale);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)blurBackgroundWithImage:(UIImage *)image animated:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurImage = [image sd_blurredImageWithRadius:30.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (animated) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    _backgroundView.alpha = 0;
                } completion:^(BOOL finished) {
                    _backgroundView.image = blurImage;
                    [UIView animateWithDuration:kAnimationDuration animations:^{
                        _backgroundView.alpha = 1;
                    } completion:nil];
                }];
            } else {
                _backgroundView.image = blurImage;
            }
        });
    });
}

- (void)configPhotoView:(HibikiPhotoView *)photoView withItem:(HibikiPhoto *)item
{
    [photoView setItem:item determinate:(_loadingStyle == HibikiPhotoViewerImageLoadingStyleDeterminate)];
}

- (void)handlePanBegin
{
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    [photoView cancelCurrentImageLoad];
    HibikiPhoto *item = [self photoAtIndex:_currentPage];
    [self setStatusBarHidden:NO];
    photoView.progressLayer.hidden = YES;
    item.sourceView.alpha = 0;
}

- (void)addGestureRecognizer
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didSingleTap:(UITapGestureRecognizer *)tap
{
    [self showDismissalAnimation];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap
{
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    HibikiPhoto *item = [self photoAtIndex:_currentPage];
    if (!item.finished) {
        return;
    }
    if (photoView.zoomScale > 1) {
        [photoView setZoomScale:1 animated:YES];
    } else {
        CGPoint location = [tap locationInView:self.view];
        CGFloat maxZoomScale = photoView.maximumZoomScale;
        CGFloat width = self.view.bounds.size.width / maxZoomScale;
        CGFloat height = self.view.bounds.size.height / maxZoomScale;
        [photoView zoomToRect:CGRectMake(location.x - width/2, location.y - height/2, width, height) animated:YES];
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    UIImage *image = photoView.imageView.image;
    if (!image) {
        return;
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        activityViewController.popoverPresentationController.sourceView = longPress.view;
        CGPoint point = [longPress locationInView:longPress.view];
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(point.x, point.y, 1, 1);
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)didPan:(UIPanGestureRecognizer *)pan
{
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    if (photoView.zoomScale > 1.1) {
        return;
    }
    
    switch (_dismissalStyle) {
        case HibikiPhotoViewerInteractiveDismissalStyleRotation:
            [self performRotationWithPan:pan];
            break;
        case HibikiPhotoViewerInteractiveDismissalStyleScale:
            [self performScaleWithPan:pan];
            break;
        case HibikiPhotoViewerInteractiveDismissalStyleSlide:
            [self performSlideWithPan:pan];
            break;
        default:
            break;
    }
}

- (void)showCancellationAnimation
{
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    HibikiPhoto *item = [self photoAtIndex:_currentPage];
    item.sourceView.alpha = 1;
    if (!item.finished) {
        photoView.progressLayer.hidden = NO;
    }
    if (_bounces && _dismissalStyle == HibikiPhotoViewerInteractiveDismissalStyleScale) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self setStatusBarHidden:YES];
            [self configPhotoView:photoView withItem:item];
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self setStatusBarHidden:YES];
            [self configPhotoView:photoView withItem:item];
        }];
    }
}

- (void)showRotationCompletionAnimationFromPoint:(CGPoint)point
{
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL startFromLeft = _startLocation.x < self.view.frame.size.width / 2;
    BOOL throwToTop = point.y < 0;
    CGFloat angle, toTranslationY;
    if (throwToTop) {
        angle = startFromLeft ? (M_PI / 2) : -(M_PI / 2);
        toTranslationY = -self.view.frame.size.height;
    } else {
        angle = startFromLeft ? -(M_PI / 2) : (M_PI / 2);
        toTranslationY = self.view.frame.size.height;
    }
    
    CGFloat angle0 = 0;
    if (_startLocation.x < self.view.frame.size.width/2) {
        angle0 = -(M_PI / 2) * (point.y / self.view.frame.size.height);
    } else {
        angle0 = (M_PI / 2) * (point.y / self.view.frame.size.height);
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(angle0);
    rotationAnimation.toValue = @(angle);
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationAnimation.fromValue = @(point.y);
    translationAnimation.toValue = @(toTranslationY);
    CAAnimationGroup *throwAnimation = [CAAnimationGroup animation];
    throwAnimation.duration = kAnimationDuration;
    throwAnimation.delegate = self;
    throwAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    throwAnimation.animations = @[rotationAnimation, translationAnimation];
    [throwAnimation setValue:@"throwAnimation" forKey:@"id"];
    [photoView.imageView.layer addAnimation:throwAnimation forKey:@"throwAnimation"];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, toTranslationY);
    CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
    photoView.imageView.transform = transform;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:nil];
}

- (void)showDismissalAnimation
{
    HibikiPhoto *item = [self photoAtIndex:_currentPage];
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    [photoView cancelCurrentImageLoad];
    [self setStatusBarHidden:NO];
    
    if (item.sourceView == nil) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
        return;
    }
    
    photoView.progressLayer.hidden = YES;
    item.sourceView.alpha = 0;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    if (_bounces) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.frame = sourceRect;
            self.view.backgroundColor = [UIColor clearColor];
            _backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.frame = sourceRect;
            self.view.backgroundColor = [UIColor clearColor];
            _backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
    }
}

- (void)showSlideCompletionAnimationFromPoint:(CGPoint)point
{
    HibikiPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = -self.view.frame.size.height;
    } else {
        toTranslationY = self.view.frame.size.height;
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissAnimated:YES];
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"id"] isEqualToString:@"throwAnimation"]) {
        [self dismissAnimated:YES];
    }
}

- (NSUInteger)photoCount
{
    if ([self.delegate respondsToSelector:@selector(numberOfPhotos)]) {
        return [self.delegate numberOfPhotos];
    }
    
    return _photoItems.count;
}

- (HibikiPhoto *)photoAtIndex:(NSUInteger)index
{
    HibikiPhoto *photo = nil;
    if ([self.delegate respondsToSelector:@selector(photoForIndex:)]) {
        photo = [self.delegate photoForIndex:index];
    } else if (index < _photoItems.count) {
        photo = [_photoItems objectAtIndex:index];
    }
    
    return photo;
}
//
//#pragma mark - HibikiPhotoDelegate
//
//- (void)photo:(HibikiPhoto *)photo isLoadingFinished:(BOOL)finished {
//    // NOOP
//}
//
//- (void)photo:(HibikiPhoto *)photo didUpdateUrl:(NSURL *)url {
//    NSUInteger index = [self.photoItems indexOfObject:photo];
//
//    if (index != NSNotFound) {
//        HibikiPhotoView *view = [self photoViewForPage:index];
//        [self configPhotoView:view withItem:photo];
//    }
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateReusableItemViews];
    [self configItemViews];
}

@end
