//
//  WTCollectionViewLayout.m
//  CollectionView流水布局
//
//  Created by 王涛 on 2017/3/30.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "WTCollectionViewLayout.h"

@interface WTCollectionViewLayout ()
{

    NSInteger _itemW;
    NSInteger _itemH;
}
@end

@implementation WTCollectionViewLayout

- (instancetype)initWithItemW:(NSInteger)itemW itemH:(NSInteger)itemH
{
    self = [super init];
    if (self) {
        _itemW = itemW;
        _itemH = itemH;
    }
    return self;
}

- (void)prepareLayout {

    [super prepareLayout];//一定要记得调用，不然没有缩放效果
    self.minimumLineSpacing = 10;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.itemSize = CGSizeMake(_itemW, _itemH);
    //设置第一个Item居中显示
    self.sectionInset = UIEdgeInsetsMake(0, CGRectGetMidX(self.collectionView.frame) - _itemW/2, 0,CGRectGetMidY(self.collectionView.frame) - _itemW/2);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    //return YES to cause the collection view to requery the layout for geometry information
    //允许重新布局
    return YES;
}

// 滚动结束后显示距离中心点最近的Item
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    
    CGRect lastRect;//随后将要将要的显示的范围
    lastRect.origin = proposedContentOffset;
    lastRect.size = self.collectionView.frame.size;
    //整体的中心
    CGFloat centerX = proposedContentOffset.x  + self.collectionView.bounds.size.width * 0.5;

    //lastRect范围内的LayoutAttributes
    NSArray *layoutAttributes = [self layoutAttributesForElementsInRect:lastRect];
    
    CGFloat adjustOffsetX = MAXFLOAT;
    // 遍历所有layoutAttributes找到距离整体中心点最近的layoutAttribute的中心点并计算它们的水平差距
    for (UICollectionViewLayoutAttributes *attrs in layoutAttributes) {
        //adjustOffsetX改变
        if (ABS(attrs.center.x - centerX) < ABS(adjustOffsetX)) {
            adjustOffsetX = attrs.center.x - centerX;
        }
    }
    //改变point使得最近Item居中显示
    return CGPointMake(proposedContentOffset.x + adjustOffsetX, proposedContentOffset.y);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {

    //可见范围
    CGRect avisibleRect;
    avisibleRect.origin = self.collectionView.contentOffset;
    avisibleRect.size   = self.collectionView.frame.size;
    //整体的中心点
    CGFloat centerX = self.collectionView.contentOffset.x  + self.collectionView.bounds.size.width * 0.5;
    NSArray *collectionViewLayoutAttribues = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in collectionViewLayoutAttribues) {
        if (!CGRectIntersectsRect(avisibleRect, attributes.frame)) {
            continue;
        }
        CGFloat itemX =  attributes.center.x;
        CGFloat distance = ABS(itemX - centerX);
        CGFloat zoomFactor = 0.0004;
        CGFloat scaling = 1/(1 + zoomFactor * distance);
        attributes.transform = CGAffineTransformMakeScale(scaling, scaling);
    }
    return collectionViewLayoutAttribues.copy;
}

@end
