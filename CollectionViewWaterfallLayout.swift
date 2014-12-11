//
//  CollectionViewWaterfallLayout.swift
//  CollectionViewWaterfallLayout
//
//  Created by Eric Cerney on 7/21/14.
//  Based on CHTCollectionViewWaterfallLayout by Nelson Tai
//  Copyright (c) 2014 Eric Cerney. All rights reserved.
//

import UIKit

let CollectionViewWaterfallElementKindSectionHeader = "CollectionViewWaterfallElementKindSectionHeader"
let CollectionViewWaterfallElementKindSectionFooter = "CollectionViewWaterfallElementKindSectionFooter"

@objc protocol CollectionViewWaterfallLayoutDelegate:UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    
    optional func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float
    
    optional func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, heightForFooterInSection section: Int) -> Float
    
    optional func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSection section: Int) -> UIEdgeInsets
    
    optional func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, insetForHeaderInSection section: Int) -> UIEdgeInsets
    
    optional func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, insetForFooterInSection section: Int) -> UIEdgeInsets
    
    optional func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSection section: Int) -> Float
    
}

class CollectionViewWaterfallLayout: UICollectionViewLayout {
    
    //MARK: Private constants
    /// How many items to be union into a single rectangle
    private let unionSize = 20;
    
    //MARK: Public Properties
    var columnCount:Int = 2 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: columnCount)
        }
    }
    var minimumColumnSpacing:Float = 10.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: minimumColumnSpacing)
        }
    }
    var minimumInteritemSpacing:Float = 10.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: minimumInteritemSpacing)
        }
    }
    var headerHeight:Float = 0.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: headerHeight)
        }
    }
    var footerHeight:Float = 0.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: footerHeight)
        }
    }
    var headerInset:UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            invalidateIfNotEqual(NSValue(UIEdgeInsets: oldValue), newValue: NSValue(UIEdgeInsets: headerInset))
        }
    }
    var footerInset:UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            invalidateIfNotEqual(NSValue(UIEdgeInsets: oldValue), newValue: NSValue(UIEdgeInsets: footerInset))
        }
    }
    var sectionInset:UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            invalidateIfNotEqual(NSValue(UIEdgeInsets: oldValue), newValue: NSValue(UIEdgeInsets: sectionInset))
        }
    }
    
    //MARK: Private Properties
    private weak var delegate: CollectionViewWaterfallLayoutDelegate?  {
        get {
            return collectionView?.delegate as? CollectionViewWaterfallLayoutDelegate
        }
    }
    private var columnHeights = [Float]()
    private var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    private var allItemAttributes = [UICollectionViewLayoutAttributes]()
    private var headersAttribute = [Int: UICollectionViewLayoutAttributes]()
    private var footersAttribute = [Int: UICollectionViewLayoutAttributes]()
    private var unionRects = [CGRect]()
    
    
    //MARK: UICollectionViewLayout Methods
    override func prepareLayout() {
        super.prepareLayout()
        
        let numberOfSections = collectionView?.numberOfSections()
        
        if numberOfSections == 0 {
            return;
        }
        
        assert(delegate!.conformsToProtocol(CollectionViewWaterfallLayoutDelegate), "UICollectionView's delegate should conform to WaterfallLayoutDelegate protocol")
        assert(columnCount > 0, "WaterfallFlowLayout's columnCount should be greater than 0")
        
        // Initialize variables
        headersAttribute.removeAll(keepCapacity: false)
        footersAttribute.removeAll(keepCapacity: false)
        unionRects.removeAll(keepCapacity: false)
        columnHeights.removeAll(keepCapacity: false)
        allItemAttributes.removeAll(keepCapacity: false)
        sectionItemAttributes.removeAll(keepCapacity: false)
        
        for  idx in 0..<columnCount {
            self.columnHeights.append(0)
        }
        
        // Create attributes
        var top:Float = 0
        var attributes: UICollectionViewLayoutAttributes
        
        for section in 0..<numberOfSections! {
            /*
            * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
            */
            var minimumInteritemSpacing: Float
            if let height = delegate?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSection: section) {
                minimumInteritemSpacing = height
            }
            else {
                minimumInteritemSpacing = self.minimumInteritemSpacing
            }
            
            var sectionInset: UIEdgeInsets
            if let inset = delegate?.collectionView?(collectionView!, layout: self, insetForSection: section) {
                sectionInset = inset
            }
            else {
                sectionInset = self.sectionInset
            }
            
            let width = Float(collectionView!.frame.size.width - sectionInset.left - sectionInset.right)
            let itemWidth = floorf((width - Float(columnCount - 1) * Float(minimumColumnSpacing)) / Float(columnCount))
            
            /*
            * 2. Section header
            */
            var headerHeight: Float
            if let height = delegate?.collectionView?(collectionView!, layout: self, heightForHeaderInSection: section) {
                headerHeight = height
            }
            else {
                headerHeight = self.headerHeight
            }
            
            var headerInset: UIEdgeInsets
            if let inset = delegate?.collectionView?(collectionView!, layout: self, insetForHeaderInSection: section) {
                headerInset = inset
            }
            else {
                headerInset = self.headerInset
            }
            
            top += Float(headerInset.top)
            
            if headerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withIndexPath: NSIndexPath(forItem: 0, inSection: section))
                attributes.frame = CGRect(x: headerInset.left, y: CGFloat(top), width: collectionView!.frame.size.width - (headerInset.left + headerInset.right), height: CGFloat(headerHeight))
                
                headersAttribute[section] = attributes
                allItemAttributes.append(attributes)
                
                top = Float(CGRectGetMaxY(attributes.frame)) + Float(headerInset.bottom)
            }
            
            top += Float(sectionInset.top)
            for idx in 0..<columnCount {
                columnHeights[idx] = top
            }
            
            
            /*
            * 3. Section items
            */
            let itemCount = collectionView!.numberOfItemsInSection(section)
            var itemAttributes = [UICollectionViewLayoutAttributes]()
            
            // Item will be put into shortest column.
            for idx in 0..<itemCount {
                let indexPath = NSIndexPath(forItem: idx, inSection: section)
                let columnIndex = shortestColumnIndex()
                
                let xOffset = Float(sectionInset.left) + Float(itemWidth + minimumColumnSpacing) * Float(columnIndex)
                let yOffset = columnHeights[columnIndex]
                let itemSize = delegate?.collectionView(collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight: Float = 0.0
                if itemSize?.height > 0 && itemSize?.width > 0 {
                    itemHeight = Float(itemSize!.height) * itemWidth / Float(itemSize!.width)
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = CGRect(x: CGFloat(xOffset), y: CGFloat(yOffset), width: CGFloat(itemWidth), height: CGFloat(itemHeight))
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[columnIndex] = Float(CGRectGetMaxY(attributes.frame)) + minimumInteritemSpacing
            }
            
            sectionItemAttributes.append(itemAttributes)
            
            /*
            * 4. Section footer
            */
            var footerHeight: Float
            var columnIndex = longestColumnIndex()
            top = columnHeights[columnIndex] - minimumInteritemSpacing + Float(sectionInset.bottom)
            
            if let height = delegate?.collectionView?(collectionView!, layout: self, heightForFooterInSection: section) {
                footerHeight = height
            }
            else {
                footerHeight = self.footerHeight
            }
            
            var footerInset: UIEdgeInsets
            if let inset = delegate?.collectionView?(collectionView!, layout: self, insetForFooterInSection: section) {
                footerInset = inset
            }
            else {
                footerInset = self.footerInset
            }
            
            top += Float(footerInset.top)
            
            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionFooter, withIndexPath: NSIndexPath(forItem: 0, inSection: section))
                attributes.frame = CGRect(x: footerInset.left, y: CGFloat(top), width: collectionView!.frame.size.width - (footerInset.left + footerInset.right), height: CGFloat(footerHeight))
                
                footersAttribute[section] = attributes
                allItemAttributes.append(attributes)
                
                top = Float(CGRectGetMaxY(attributes.frame)) + Float(footerInset.bottom)
            }
            
            for idx in 0..<columnCount {
                columnHeights[idx] = top
            }
        }
        
        // Build union rects
        var idx = 0
        let itemCounts = allItemAttributes.count
        
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(CGRectUnion(rect1, rect2))
            ++idx
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        let numberOfSections = collectionView?.numberOfSections()
        if numberOfSections == 0 {
            return CGSizeZero
        }
        
        var contentSize = collectionView?.bounds.size
        contentSize?.height = CGFloat(columnHeights[0])
        
        return contentSize!
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if indexPath.section >= sectionItemAttributes.count {
            return nil
        }
        
        if indexPath.item >= sectionItemAttributes[indexPath.section].count {
            return nil
        }
        
        return sectionItemAttributes[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var attribute: UICollectionViewLayoutAttributes?
        
        if elementKind == CollectionViewWaterfallElementKindSectionHeader {
            attribute = headersAttribute[indexPath.section]
        }
        else if elementKind == CollectionViewWaterfallElementKindSectionFooter {
            attribute = footersAttribute[indexPath.section]
        }
        
        return attribute
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject] {
        var begin:Int = 0
        var end: Int = unionRects.count
        var attrs = [UICollectionViewLayoutAttributes]()
        
        for i in 0..<unionRects.count {
            if CGRectIntersectsRect(rect, unionRects[i]) {
                begin = i * unionSize
                break
            }
        }
        for i in reverse(0..<unionRects.count) {
            if CGRectIntersectsRect(rect, unionRects[i]) {
                end = min((i+1) * unionSize, allItemAttributes.count)
                break
            }
        }
        for var i = begin; i < end; i++ {
            let attr = allItemAttributes[i]
            if CGRectIntersectsRect(rect, attr.frame) {
                attrs.append(attr)
            }
        }
        
        return Array(attrs)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        let oldBounds = collectionView?.bounds
        if CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds!) {
            return true
        }
        
        return false
    }
    
    //MARK: Private Methods
    private func shortestColumnIndex() -> Int {
        var index: Int = 0
        var shortestHeight = MAXFLOAT
        
        for (idx, height) in enumerate(columnHeights) {
            if height < shortestHeight {
                shortestHeight = height
                index = idx
            }
        }
        
        return index
    }
    
    private func longestColumnIndex() -> Int {
        var index: Int = 0
        var longestHeight:Float = 0
        
        for (idx, height) in enumerate(columnHeights) {
            if height > longestHeight {
                longestHeight = height
                index = idx
            }
        }
        
        return index
    }
    
    private func invalidateIfNotEqual(oldValue: AnyObject, newValue: AnyObject) {
        if !oldValue.isEqual(newValue) {
            invalidateLayout()
        }
    }
}
