//
//  HibikiProgressLayer.h
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

@interface HibikiProgressLayer : CAShapeLayer

#pragma mark - Properties
@property (nonatomic, assign, readonly) BOOL isSpinning;

#pragma mark - Methods
- (instancetype)initWithFrame:(CGRect)frame;
- (void)startSpinning;
- (void)stopSpinning;

@end

NS_ASSUME_NONNULL_END
