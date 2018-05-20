Hibiki
==============

Hibiki is a photo viewer based on the fantastic [KSPhotoBrowser](https://github.com/skx926/KSPhotoBrowser) framework by Kyle Sun. It contains fewer(!) features and allows for lazy creation of photos, in case you want to provide those objects at a later point when dealing with extremely large collections.

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/skx926/KSPhotoBrowser/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/Hibiki.svg?style=flat)](http://cocoapods.org/?q=Hibiki)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/Hibiki.svg?style=flat)](http://cocoapods.org/?q=Hibiki)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%208.0%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;

Usage
==============
### 1. Create the viewer object and assign a delegate
```objc
HibikiPhotoViewer *viewer = [[HibikiPhotoViewer alloc] initWithDelegate:self selectedIndex:indexPath.row];
[viewer showFromViewController:self];
```

### 2. Implement the delegate functionality

```
- (HibikiPhoto *)photoForIndex:(NSUInteger)index
{
    PhotoCell *cell = (PhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSURL *url = self.yourImageUrls[index]
    HibikiPhoto *photo = [[HibikiPhoto alloc] initWithSourceView:cell.imageView imageUrl:url];
    
    return photo;
}
```

Installation
==============
### Cocoapods
1. Update cocoapods to the latest version.
2. Add `pod 'Hibiki'` to your Podfile.
3. Run `pod install` or `pod update`.
4. `#import <Hibiki/Hibiki.h>` or `import Hibiki`.

License
==============
Hibiki is provided under the MIT license. See LICENSE file for details.
