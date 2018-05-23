//
//  HibikiPhoto.m
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

#import "HibikiPhoto.h"

@interface HibikiPhoto ()

#pragma mark - Properties
@property (nonatomic, strong, readwrite) UIImage *thumbImage;
@property (nonatomic, strong, readwrite) UIImage *image;

@end

@implementation HibikiPhoto

#pragma mark - HibikiPhoto

+ (instancetype)itemWithSourceView:(UIView *)view thumbImage:(UIImage *)image imageUrl:(NSURL *)url
{
    return [[HibikiPhoto alloc] initWithSourceView:view thumbImage:image imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view imageUrl:(NSURL *)url
{
    return [[HibikiPhoto alloc] initWithSourceView:view imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view image:(UIImage *)image
{
    return [[HibikiPhoto alloc] initWithSourceView:view image:image];
}

- (instancetype)initWithSourceView:(UIView *)view thumbImage:(UIImage *)image imageUrl:(NSURL *)url
{
    self = [super init];
    
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = url;
    }
    
    return self;
}

- (instancetype)initWithSourceView:(UIImageView *)view imageUrl:(NSURL *)url
{
    return [self initWithSourceView:view thumbImage:view.image imageUrl:url];
}

- (instancetype)initWithSourceView:(UIImageView *)view image:(UIImage *)image
{
    self = [super init];
    
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = nil;
        _image = image;
    }
    
    return self;
}

- (void)setFinished:(BOOL)finished
{
    if (_finished != finished) {
        _finished = finished;
        
        if ([self.delegate respondsToSelector:@selector(photo:isLoadingFinished:)]) {
            [self.delegate photo:self isLoadingFinished:_finished];
        }
    }
}

- (void)setImageUrl:(NSURL *)imageUrl
{
    if (_imageUrl != imageUrl) {
        _imageUrl = imageUrl;
        
        if ([self.delegate respondsToSelector:@selector(photo:didUpdateUrl:)]) {
            [self.delegate photo:self didUpdateUrl:_imageUrl];
        }
    }
}

@end
