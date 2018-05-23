//
//  PreviewViewController.m
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

#import "PreviewViewController.h"
#import "YYWebImage.h"
#import "PhotoCell.h"

@interface PreviewViewController ()<HibikiPhotoViewerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

#pragma mark - Properties
@property (nonatomic, strong, readwrite) NSMutableArray *urls;
@property (nonatomic, weak, readwrite) IBOutlet UICollectionView *collectionView;

@end

@implementation PreviewViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *urls = @[@"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f12r9ku6wjj20u00mhn22.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1f01hkxyjhej20u00jzacj.jpg",
                      @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f01hhs2omoj20u00jzwh9.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1exkkw984e3j20u00miacm.jpg",
                      @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1ezvdc5dt1pj20ku0kujt7.jpg",
                      @"http://ww3.sinaimg.cn/bmiddle/a15bd3a5jw1ew68tajal7j20u011iacr.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg"];
    _urls = @[].mutableCopy;
    for (int i = 0; i < 10; i++) {
        [_urls addObjectsFromArray:urls];
    }
    
    [HibikiPhotoViewer setImageManagerClass:HibikiImageManager.class];
}

#pragma mark - PreviewViewController

// If you need to retireve the url lazily... (1/2)
//
//- (void)urlForItemAtIndex:(NSUInteger)index completion:(PreviewViewControllerURLRequestCompletion)completion
//{
//    if (completion == nil) {
//        return;
//    }
//
//    NSURL *url = [NSURL URLWithString:[self.urls[index] stringByReplacingOccurrencesOfString:@"bmiddle" withString:@"large"]];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        completion(url);
//    });
//}

#pragma mark - HibikiPhotoViewerDelegate

- (void)photoViewer:(HibikiPhotoViewer *)browser didSelectItem:(HibikiPhoto *)item atIndex:(NSUInteger)index
{
    NSLog(@"selected index: %ld", index);
}

- (HibikiPhoto * _Nullable)photoForIndex:(NSUInteger)index
{
    PhotoCell *cell = (PhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSURL *url = [NSURL URLWithString:[self.urls[index] stringByReplacingOccurrencesOfString:@"bmiddle" withString:@"large"]];
    HibikiPhoto *photo = [[HibikiPhoto alloc] initWithSourceView:cell.imageView imageUrl:url];
    
    // If you need to retireve the url lazily... (2/2)
    //
    //    __weak typeof(photo) wphoto = photo;
    //    [self urlForItemAtIndex:index completion:^(NSURL *maybeUrl) {
    //        __strong typeof(wphoto) sphoto = wphoto;
    //        sphoto.imageUrl = maybeUrl;
    //    }];

    return photo;
}

- (NSUInteger)numberOfPhotos
{
    return self.urls.count;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.imageView.yy_imageURL = [NSURL URLWithString:_urls[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HibikiPhotoViewer *browser = [[HibikiPhotoViewer alloc] initWithDelegate:self selectedIndex:indexPath.row];
    browser.dismissalStyle = _dismissalStyle;
    browser.backgroundStyle = _backgroundStyle;
    browser.loadingStyle = _loadingStyle;
    browser.bounces = _bounces;
    [browser showFromViewController:self];
}

@end
