//
//  MSCycleScrollView.m
//  MSCycleScrollView
//
//  Created by TuBo on 2018/12/28.
//  Copyright © 2018 turBur. All rights reserved.
//

#import "MSCycleScrollView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "MSCollectionViewCell.h"
#import "UIView+MSExtension.h"
#import "MSPageControl.h"
#import "MSAnimatedDotView.h"

#define kCycleScrollViewInitialPageControlDotSize CGSizeMake(8, 8)
NSString * const ID = @"MSCycleScrollViewCell";

@interface MSCycleScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>


@property (nonatomic, weak) UICollectionView *mainView; // 显示图片的collectionView
@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray *imagePathsGroup;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger totalItemsCount;
@property (nonatomic, weak) UIControl *pageControl;

@property (nonatomic, strong) UIImageView *backgroundImageView; // 当imageURLs为空时的背景图

@end

@implementation MSCycleScrollView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialization];
    [self setupMainView];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)initialization{
    
    self.backgroundColor = [UIColor lightGrayColor];

    _pageControlAliment = kMSPageContolAlimentCenter;
    _autoScrollTimeInterval = 3.0;
    _titleLabelTextColor = [UIColor whiteColor];
    _titleLabelTextFont= [UIFont systemFontOfSize:14];
    _titleLabelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _titleLabelHeight = 30;
    _titleLabelTextAlignment = NSTextAlignmentLeft;
    _autoScroll = YES;
    _infiniteLoop = YES;
    _showPageControl = YES;
    _pageControlDotSize = kCycleScrollViewInitialPageControlDotSize;
    _pageControlBottomOffset = 0;
    _pageControlRightOffset = 0;
    _pageControlStyle = kMSPageContolStyleClassic;
    _hidesForSinglePage = YES;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _bannerImageViewContentMode = UIViewContentModeScaleToFill;
    _dotViewClass = [MSAnimatedDotView class];
}

// 设置显示图片的collectionView
- (void)setupMainView{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout = flowLayout;
    
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [mainView registerClass:[MSCollectionViewCell class] forCellWithReuseIdentifier:ID];
    
    mainView.dataSource = self;
    mainView.delegate = self;
    mainView.scrollsToTop = NO;
    [self addSubview:mainView];
    
    //ios11 兼容性适配
    if (@available(iOS 11.0, *)) {
        mainView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        mainView.insetsLayoutMarginsFromSafeArea = NO;
    }
    
    _mainView = mainView;
}

+ (instancetype)cycleViewWithFrame:(CGRect)frame delegate:(id<MSCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage
{
    MSCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    cycleScrollView.placeholderImage = placeholderImage;

    return cycleScrollView;
}

+ (instancetype)cycleViewWithFrame:(CGRect)frame InfiniteLoop:(BOOL)infiniteLoop locationImageNames:(NSArray *)imageNames
{
    MSCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.infiniteLoop = infiniteLoop;
    cycleScrollView.locationImageNames = [NSMutableArray arrayWithArray:imageNames];
    return cycleScrollView;
}

#pragma mark - properties

- (void)setDelegate:(id<MSCycleScrollViewDelegate>)delegate{
    _delegate = delegate;

    if ([self.delegate respondsToSelector:@selector(customCellClassForCycleScrollView:)] && [self.delegate customCellClassForCycleScrollView:self]) {
        [self.mainView registerClass:[self.delegate customCellClassForCycleScrollView:self] forCellWithReuseIdentifier:ID];
    }else if ([self.delegate respondsToSelector:@selector(customCellNibForCycleScrollView:)] && [self.delegate customCellNibForCycleScrollView:self]) {
        [self.mainView registerNib:[self.delegate customCellNibForCycleScrollView:self] forCellWithReuseIdentifier:ID];
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    _placeholderImage = placeholderImage;
    
    if (!self.backgroundImageView ) {
        
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self insertSubview:bgImageView belowSubview:self.mainView];
        self.backgroundImageView = bgImageView;
    }
    self.backgroundImageView.image = placeholderImage;
}
    
-(void)setOnlyDisplayText:(BOOL)onlyDisplayText{
    _onlyDisplayText = onlyDisplayText;
    self.backgroundImageView.image = nil;
}

    
- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self setupPageControl];
    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageContol = (MSPageControl *)_pageControl;
        pageContol.pageDotSize = pageControlDotSize;
    }
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;

    _pageControl.hidden = !showPageControl;
}

-(void)setSpacingBetweenDots:(CGFloat)spacingBetweenDots{
    _spacingBetweenDots = spacingBetweenDots;
    [self setupPageControl];
    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageControl = (MSPageControl *)_pageControl;
        pageControl.spacingBetweenDots = spacingBetweenDots;
    }
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageControl = (MSPageControl *)_pageControl;
        pageControl.dotColor = currentPageDotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;

    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;

    if (self.pageControlStyle != kMSPageContolStyleAnimated) {
        self.pageControlStyle = kMSPageContolStyleAnimated;
    }

    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage
{
    _pageDotImage = pageDotImage;

    if (self.pageControlStyle != kMSPageContolStyleAnimated) {
        self.pageControlStyle = kMSPageContolStyleAnimated;
    }

    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

-(void)setDotViewClass:(Class)dotViewClass{
    _dotViewClass = dotViewClass;
    [self setupPageControl];
    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageControl = (MSPageControl *)_pageControl;
        pageControl.dotViewClass = dotViewClass;
    }
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot
{
    if (!image || !self.pageControl) return;

    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageControl = (MSPageControl *)_pageControl;
        if (isCurrentPageDot) {
            pageControl.currentDotImage = image;
        } else {
            pageControl.dotImage = image;
        }
    }
}

- (void)setInfiniteLoop:(BOOL)infiniteLoop
{
    _infiniteLoop = infiniteLoop;

    if (self.imagePathsGroup.count) {
        self.imagePathsGroup = self.imagePathsGroup;
    }
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;

    [self invalidateTimer];

    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection{
    _scrollDirection = scrollDirection;

    _flowLayout.scrollDirection = scrollDirection;
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;

    [self setAutoScroll:self.autoScroll];
}

-(void)setPageControlStyle:(kMSPageContolStyle)pageControlStyle{
    _pageControlStyle = pageControlStyle;
    
    [self setupPageControl];
}


- (void)setImagePathsGroup:(NSArray *)imagePathsGroup
{
    [self invalidateTimer];

    _imagePathsGroup = imagePathsGroup;

    _totalItemsCount = self.infiniteLoop ? self.imagePathsGroup.count * 100 : self.imagePathsGroup.count;

    if (imagePathsGroup.count > 1) { // 由于 !=1 包含count == 0等情况
        self.mainView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    } else {
        self.mainView.scrollEnabled = NO;
        [self invalidateTimer];
    }

    [self setupPageControl];
    
//    [self.mainView reloadData];

    [UIView performWithoutAnimation:^{
        [self.mainView reloadData];
    }];
}

-(void)setImageUrls:(NSArray *)imageUrls{
    _imageUrls = imageUrls;
    
    NSMutableArray *temp = [NSMutableArray new];
    [_imageUrls enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    
    self.imagePathsGroup = [temp copy];
    
    [self.mainView reloadData];

}


-(void)setLocationImageNames:(NSArray *)locationImageNames{
    _locationImageNames = locationImageNames;
    self.imagePathsGroup = [locationImageNames copy];
}

-(void)setTitles:(NSArray *)titles{
    _titles = titles;
    if (self.onlyDisplayText) {
        NSMutableArray *temp = [NSMutableArray new];
        for (int i = 0; i < titles.count; i++) {
            [temp addObject:@""];
        }
        self.backgroundColor = [UIColor clearColor];
        self.imageUrls = [temp copy];
    }
}
    
- (void)setBannerImageViewContentMode:(UIViewContentMode)bannerImageViewContentMode {
    self.backgroundImageView.contentMode = bannerImageViewContentMode;
    _bannerImageViewContentMode = bannerImageViewContentMode;
}


    
- (void)disableScrollGesture {
    self.mainView.canCancelContentTouches = NO;
    for (UIGestureRecognizer *gesture in self.mainView.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.mainView removeGestureRecognizer:gesture];
        }
    }
}

#pragma mark - actions

- (void)setupTimer
{
    [self invalidateTimer]; // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)setupPageControl
{
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整

    if (!self.showPageControl) return;
    
    if (self.imagePathsGroup.count == 0 || self.onlyDisplayText) return;

    if ((self.imagePathsGroup.count == 1) && self.hidesForSinglePage) return;

    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];

    switch (self.pageControlStyle) {
        case kMSPageContolStyleAnimated:
        {
            MSPageControl *pageControl = [[MSPageControl alloc] init];
            pageControl.numberOfPages = self.imagePathsGroup.count;
            pageControl.dotColor = self.currentPageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;

        case kMSPageContolStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.numberOfPages = self.imagePathsGroup.count;
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        case kMSPageContolStyleCustomer:
        {
            MSPageControl *pageControl = [[MSPageControl alloc] init];
            pageControl.numberOfPages = self.imagePathsGroup.count;
            pageControl.dotColor = self.currentPageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            pageControl.dotViewClass = self.dotViewClass;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        default:
            break;
    }

    // 重设pagecontroldot图片
    if (self.currentPageDotImage) {
        self.currentPageDotImage = self.currentPageDotImage;
    }
    if (self.pageDotImage) {
        self.pageDotImage = self.pageDotImage;
    }
}


- (void)automaticScroll
{
    if (0 == _totalItemsCount) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(int)targetIndex
{
    if (targetIndex >= _totalItemsCount) {
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (int)currentIndex
{
    if (_mainView.sd_width == 0 || _mainView.sd_height == 0) {
        return 0;
    }

    int index = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_mainView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    } else {
        index = (_mainView.contentOffset.y + _flowLayout.itemSize.height * 0.5) / _flowLayout.itemSize.height;
    }

    return MAX(0, index);
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.imagePathsGroup.count;
}

- (void)clearCache
{
    [[self class] clearImagesCache];
}

+ (void)clearImagesCache
{
    [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:nil];
}

#pragma mark - life circles

- (void)layoutSubviews
{
    self.delegate = self.delegate;

    [super layoutSubviews];

    _flowLayout.itemSize = self.frame.size;

    _mainView.frame = self.bounds;
    if (_mainView.contentOffset.x == 0 &&  _totalItemsCount) {
        int targetIndex = 0;
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }

    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageControl = (MSPageControl *)_pageControl;
        if (!(self.pageDotImage && self.currentPageDotImage && CGSizeEqualToSize(kCycleScrollViewInitialPageControlDotSize, self.pageControlDotSize))) {
            pageControl.pageDotSize = self.pageControlDotSize;
        }
        size = [pageControl sizeForNumberOfPages:self.imagePathsGroup.count];
    } else {
        size = CGSizeMake(self.imagePathsGroup.count * self.pageControlDotSize.width * 1.5, self.pageControlDotSize.height);
    }
    CGFloat x = (self.sd_width - size.width) * 0.5;
    if (self.pageControlAliment == kMSPageContolAlimentRight) {
        x = self.mainView.sd_width - size.width - 10;
    }
    CGFloat y = self.mainView.sd_height - size.height - 10;

    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageControl = (MSPageControl *)_pageControl;
        [pageControl sizeToFit];
    }

    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.y -= self.pageControlBottomOffset;
    pageControlFrame.origin.x -= self.pageControlRightOffset;
    self.pageControl.frame = pageControlFrame;
    self.pageControl.hidden = !_showPageControl;

    if (self.backgroundImageView) {
        self.backgroundImageView.frame = self.bounds;
    }

}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}

#pragma mark - public actions

- (void)adjustWhenControllerViewWillAppera
{
    long targetIndex = [self currentIndex];
    if (targetIndex < _totalItemsCount) {
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];

    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];

    if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:cycleScrollView:)] &&
        [self.delegate respondsToSelector:@selector(customCellClassForCycleScrollView:)] && [self.delegate customCellClassForCycleScrollView:self]) {
        [self.delegate setupCustomCell:cell forIndex:itemIndex cycleScrollView:self];
        return cell;
    }else if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:cycleScrollView:)] &&
              [self.delegate respondsToSelector:@selector(customCellNibForCycleScrollView:)] && [self.delegate customCellNibForCycleScrollView:self]) {
        [self.delegate setupCustomCell:cell forIndex:itemIndex cycleScrollView:self];
        return cell;
    }

    NSString *imagePath = self.imagePathsGroup[itemIndex];

    if (!self.onlyDisplayText && [imagePath isKindOfClass:[NSString class]]) {
        if ([imagePath hasPrefix:@"http"]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
        } else {
            UIImage *image = [UIImage imageNamed:imagePath];
            if (!image) {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            cell.imageView.image = image;
        }
    } else if (!self.onlyDisplayText && [imagePath isKindOfClass:[UIImage class]]) {
        cell.imageView.image = (UIImage *)imagePath;
    }

    if (_titles.count && itemIndex < _titles.count) {
        cell.title = _titles[itemIndex];
    }

    if (!cell.hasConfigured) {
        cell.titleLabelBackgroundColor = self.titleLabelBackgroundColor;
        cell.titleLabelHeight = self.titleLabelHeight;
        cell.titleLabelTextAlignment = self.titleLabelTextAlignment;
        cell.titleLabelTextColor = self.titleLabelTextColor;
        cell.titleLabelTextFont = self.titleLabelTextFont;
        cell.hasConfigured = YES;
        cell.imageView.contentMode = self.bannerImageViewContentMode;
        cell.clipsToBounds = YES;
        cell.onlyDisplayText = self.onlyDisplayText;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
    }
    
    if (self.clickItemOperationBlock) {
        self.clickItemOperationBlock([self pageControlIndexWithCurrentCellIndex:indexPath.item]);
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];

    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
        MSPageControl *pageControl = (MSPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:self.mainView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];

    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToIndex:)]) {
        [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
    } else if (self.itemDidScrollOperationBlock) {
        self.itemDidScrollOperationBlock(indexOnPageControl);
    }
}

- (void)makeScrollViewScrollToIndex:(NSInteger)index{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
    if (0 == _totalItemsCount) return;

    [self scrollToIndex:(int)(_totalItemsCount * 0.5 + index)];

    if (self.autoScroll) {
        [self setupTimer];
    }
}


@end


