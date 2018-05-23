//
//  ViewController.h
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

@import UIKit;

#import "HibikiPhotoViewer.h"

typedef void(^PreviewViewControllerURLRequestCompletion)(NSURL *);

@interface PreviewViewController : UIViewController

#pragma mark - Properies
@property (nonatomic, assign, readwrite) HibikiPhotoViewerInteractiveDismissalStyle dismissalStyle;
@property (nonatomic, assign, readwrite) HibikiPhotoViewerBackgroundStyle backgroundStyle;
@property (nonatomic, assign, readwrite) HibikiPhotoViewerPageIndicatorStyle pageindicatorStyle;
@property (nonatomic, assign, readwrite) HibikiPhotoViewerImageLoadingStyle loadingStyle;
@property (nonatomic, assign, readwrite) BOOL bounces;

@end

