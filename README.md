CollectionViewWaterfallLayout
========================

Pinterest inspired layout for UICollectionViews

**Note: Updated for Swift 2.0 and cocoapods**

**CollectionViewWaterfallLayout** is a subclass of [UICollectionViewLayout](https://developer.apple.com/library/ios/documentation/uikit/reference/UICollectionViewLayout_class/Reference/Reference.html) written completely in Swift. This class is based off [CHTCollectionViewWaterfallLayout](https://github.com/chiahsien/CHTCollectionViewWaterfallLayout) which was written by [chiahsien](https://github.com/chiahsien) in Objective C. This class tries to use as many new Swifty things to keep the code updated with current design patterns.

The original layout was inspired by [Pinterest](http://www.pinterest.com/).

Features
-----------
* Easy to use - If you are used to working with UICollectionViewFlowLayout, this should feel natural
* Highly Customizable
* Outstanding Performance
* Supports headers and footers

Screen Shots
-----------
![Real World Example](/Screenshots/RealWorldExample.png?raw=true "Real World Example") 
![Demo Example](/Screenshots/DemoExample.png?raw=true "Demo Example")

Prerequisites
-----------
* ARC
* iOS 7+
* Xcode 7+
* Swift 2.0

Installation
-----------
CollectionViewWaterfallLayout is available through CocoaPods. To install it, simply add the following line to your Podfile:
```
pod "CollectionViewWaterfallLayout"
```

How to Use
-----------
Check out the demo project for an example using storyboards to set up the views, and that programmatically creates and customizes the waterfall layout.

#### Customizable Properties
Below are the public properties and their default values that you can change to customize the layout
``` swift
var columnCount:Int = 2
var minimumColumnSpacing:Float = 10.0
var minimumInteritemSpacing:Float = 10.0
var headerHeight:Float = 0.0
var footerHeight:Float = 0.0
var headerInset:UIEdgeInsets = UIEdgeInsetsZero
var footerInset:UIEdgeInsets = UIEdgeInsetsZero
var sectionInset:UIEdgeInsets = UIEdgeInsetsZero
```

#### Required Protocol
Your collection view's delegate must conforms to `CollectionViewWaterfallLayoutDelegate` protocol and implement the required method, all you need to do is return the original size of the item:

``` swift
func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
```

[Code Only Example](https://gist.github.com/entotsu/764b496d7d21d126ae48)

Limitation
----------
* Only vertical scrolling is supported.
* No decoration view.

License
-------
CollectionViewWaterfallLayout is available under the MIT license. See the LICENSE file for more info.
