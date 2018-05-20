//
//  DemoViewController.m
//  HibikiPhotoViewer
//
//  Copyright © 2018 Philip Kluz. All rights reserved.
//
//  Based on KSPhotoBrowser created by Kyle Sun on 2017-05-22.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//  Released under the MIT license.
//

#import "DemoViewController.h"
#import "PreviewViewController.h"
#import "YYWebImage.h"

@interface DemoViewController ()

#pragma mark - Properties

@property (nonatomic, weak, readwrite) IBOutlet UISegmentedControl *dismissalSegementedControl;
@property (nonatomic, weak, readwrite) IBOutlet UISegmentedControl *backgroundSegementedControl;
@property (nonatomic, weak, readwrite) IBOutlet UISegmentedControl *pageSegementedControl;
@property (nonatomic, weak, readwrite) IBOutlet UISegmentedControl *loadingSegementedControl;
@property (nonatomic, weak, readwrite) IBOutlet UISwitch *bouncesSwitch;

@end

@implementation DemoViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PreviewViewController *preview = [segue destinationViewController];
    preview.dismissalStyle = _dismissalSegementedControl.selectedSegmentIndex;
    preview.backgroundStyle = _backgroundSegementedControl.selectedSegmentIndex;
    preview.pageindicatorStyle = _pageSegementedControl.selectedSegmentIndex;
    preview.loadingStyle = _loadingSegementedControl.selectedSegmentIndex;
    preview.bounces = _bouncesSwitch.on;
}

// MARK: - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 7) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
        [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
    }
}

@end
