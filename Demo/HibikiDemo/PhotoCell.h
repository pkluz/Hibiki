//
//  PhotoCell.h
//  HibikiPhotoViewerDemo
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

@import UIKit;

@interface PhotoCell : UICollectionViewCell

#pragma mark - Properties
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *imageView;

@end
