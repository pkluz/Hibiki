//
//  HibikiPhotoViewer.h
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

@import UIKit;

#import "HibikiPhoto.h"
#import "HibikiImageManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HibikiPhotoViewerInteractiveDismissalStyle) {
    HibikiPhotoViewerInteractiveDismissalStyleRotation,
    HibikiPhotoViewerInteractiveDismissalStyleScale,
    HibikiPhotoViewerInteractiveDismissalStyleSlide,
    HibikiPhotoViewerInteractiveDismissalStyleNone
};

typedef NS_ENUM(NSUInteger, HibikiPhotoViewerBackgroundStyle) {
    HibikiPhotoViewerBackgroundStyleBlurPhoto,
    HibikiPhotoViewerBackgroundStyleBlur,
    HibikiPhotoViewerBackgroundStyleBlack
};

typedef NS_ENUM(NSUInteger, HibikiPhotoViewerPageIndicatorStyle) {
    HibikiPhotoViewerPageIndicatorStyleDot,
    HibikiPhotoViewerPageIndicatorStyleText
};

typedef NS_ENUM(NSUInteger, HibikiPhotoViewerImageLoadingStyle) {
    HibikiPhotoViewerImageLoadingStyleIndeterminate,
    HibikiPhotoViewerImageLoadingStyleDeterminate
};

@protocol HibikiPhotoViewerDelegate;
@protocol HibikiImageManager;

@interface HibikiPhotoViewer : UIViewController

#pragma mark - Properties
@property (nonatomic, assign, readwrite) HibikiPhotoViewerInteractiveDismissalStyle dismissalStyle;
@property (nonatomic, assign, readwrite) HibikiPhotoViewerBackgroundStyle backgroundStyle;
@property (nonatomic, assign, readwrite) HibikiPhotoViewerImageLoadingStyle loadingStyle;
@property (nonatomic, assign, readwrite) BOOL bounces;
@property (nonatomic, weak, nullable, readwrite) id<HibikiPhotoViewerDelegate> delegate;

#pragma mark - Methods
+ (void)setImageManagerClass:(Class<HibikiImageManager>)cls;

+ (instancetype)browserWithPhotoItems:(NSArray<HibikiPhoto *> *)photoItems selectedIndex:(NSUInteger)selectedIndex;

- (instancetype)initWithDelegate:(id<HibikiPhotoViewerDelegate>)delegate selectedIndex:(NSUInteger)selectedIndex;

- (instancetype)initWithPhotoItems:(NSArray<HibikiPhoto *> *)photoItems selectedIndex:(NSUInteger)selectedIndex;

- (void)showFromViewController:(UIViewController *)vc;

@end

@protocol HibikiPhotoViewerDelegate <NSObject>

#pragma mark - Methods
- (HibikiPhoto * _Nullable)photoForIndex:(NSUInteger)index;
- (NSUInteger)numberOfPhotos;
- (void)photoViewer:(HibikiPhotoViewer *)viewer didSelectItem:(HibikiPhoto *)item atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
