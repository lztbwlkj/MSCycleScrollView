//
//  MSCycleScrollView.m
//  MSCycleScrollView
//
//  Created by TuBo on 2018/12/28.
//  Copyright © 2018 turBur. All rights reserved.
//

#import "MSCycleScrollView.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "MSCollectionViewCell.h"
#import "UIView+MSExtension.h"

#define kCycleScrollViewInitialPageControlDotSize CGSizeMake(8, 8)
NSString * const ID = @"MSCycleScrollViewCell";

@interface MSCycleScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>


@property (nonatomic, weak) UICollectionView *mainView; // 显示图片的collectionView
@property (nonatomic, strong) MSPageControl *pageControl;

@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray *imagePathsGroup;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger totalItemsCount;

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

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self initialization];
//        [self setupMainView];
//    }
//    return self;
//}

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
    _hidesForSinglePage = YES;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _bannerImageViewContentMode = UIViewContentModeScaleToFill;
    _spacingBetweenDots = 8;
    _currentWidthMultiple = 1;//当前选中点宽度与未选中点的宽度的倍数，默认为1倍
    _dotsIsSquare = NO;//默认是圆点
    
    _currentDotBorderWidth = 0;
    _currentDotBorderColor = [UIColor clearColor];
    
    _dotBorderColor = [UIColor whiteColor];
    _dotBorderWidth = 0;
    
    _pageControlStyle = MSPageControlStyleSystem;
    _pageControlAnimation = MSPageControlAnimationNone;
    
    _textFont = [UIFont systemFontOfSize:9];
    _textColor = [UIColor blackColor];
}


+ (instancetype)cycleViewWithFrame:(CGRect)frame InfiniteLoop:(BOOL)infiniteLoop locationImageNames:(NSArray *)imageNames{
    MSCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.infiniteLoop = infiniteLoop;
    cycleScrollView.locationImageNames = [NSMutableArray arrayWithArray:imageNames];
    return cycleScrollView;
}

+ (instancetype)cycleViewWithFrame:(CGRect)frame imageUrls:(NSArray *)imageUrls
{
    MSCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.imageUrls = [NSMutableArray arrayWithArray:imageUrls];
    return cycleScrollView;
}

+(instancetype)cycleViewWithFrame:(CGRect)frame delegate:(id<MSCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage
{
    MSCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    cycleScrollView.placeholderImage = placeholderImage;
    
    return cycleScrollView;
}


// 设置显示图片的collectionView
- (void)setupMainView{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
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


#pragma mark - SD原有属性
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
    
    if (!self.backgroundImageView) {
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.mainView.bounds];
        bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self insertSubview:bgImageView belowSubview:self.mainView];
        self.backgroundImageView = bgImageView;
    }
    
    self.backgroundImageView.image = placeholderImage;
}
    
- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    self.pageControl.pageDotSize = pageControlDotSize;
}

- (void)setShowPageControl:(BOOL)showPageControl{
    _showPageControl = showPageControl;
    _pageControl.hidden = !showPageControl;
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    if (_pageDotColor == pageDotColor) return;
    _pageDotColor = pageDotColor;
    self.pageControl.dotColor = pageDotColor;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    self.pageControl.currentDotColor = currentPageDotColor;
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;
    if (self.pageControlStyle != MSPageControlStyleSystem) {
        self.pageControlStyle = MSPageControlStyleSystem;
    }
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage
{
    _pageDotImage = pageDotImage;
    if (self.pageControlStyle != MSPageControlStyleSystem) {
        self.pageControlStyle = MSPageControlStyleSystem;
    }
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
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


-(void)setSpacingBetweenDots:(CGFloat)spacingBetweenDots{
    if (_spacingBetweenDots == spacingBetweenDots) return;

    _spacingBetweenDots = spacingBetweenDots;
    self.pageControl.spacingBetweenDots = spacingBetweenDots;
}

-(void)setInfiniteLoop:(BOOL)infiniteLoop{
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

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    [self setAutoScroll:self.autoScroll];
}


-(void)setPageControlStyle:(MSPageControlStyle)pageControlStyle{
    if (_pageControlStyle == pageControlStyle) return;
    _pageControlStyle = pageControlStyle;
    self.pageControl.pageControlStyle = pageControlStyle;
//    [self setupPageControl];
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
    
    [self setupPageControl];
    
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

#pragma mark - 新增属性

- (void)setDotBorderWidth:(CGFloat)dotBorderWidth{
    if (_dotBorderWidth == dotBorderWidth) return;
    
    _dotBorderWidth = dotBorderWidth;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.dotBorderWidth = dotBorderWidth;
}

-(void)setCurrentDotBorderWidth:(CGFloat)currentDotBorderWidth{
    if (_currentDotBorderWidth == currentDotBorderWidth) return;
    _currentDotBorderWidth = currentDotBorderWidth;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.currentDotBorderWidth = currentDotBorderWidth;

}

-(void)setDotBorderColor:(UIColor *)dotBorderColor{
    if (_dotBorderColor == dotBorderColor) return;
    _dotBorderColor = dotBorderColor;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.dotBorderColor = dotBorderColor;

}

-(void)setPageControlAnimation:(MSPageControlAnimation)pageControlAnimation{
    if (_pageControlAnimation == pageControlAnimation) return;
    _pageControlAnimation = pageControlAnimation;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.pageControlAnimation = pageControlAnimation;
}

-(void)setCurrentDotBorderColor:(UIColor *)currentDotBorderColor{
    if (_currentDotBorderColor == currentDotBorderColor) return;
    
    _currentDotBorderColor = currentDotBorderColor;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.currentDotBorderColor = currentDotBorderColor;
}

-(void)setCurrentWidthMultiple:(CGFloat)currentWidthMultiple{
    if (_currentWidthMultiple == currentWidthMultiple) return;
    
    _currentWidthMultiple = currentWidthMultiple;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.currentWidthMultiple = currentWidthMultiple;
}

-(void)setDotsIsSquare:(BOOL)dotsIsSquare{
    if (_dotsIsSquare == dotsIsSquare) return;
    _dotsIsSquare = dotsIsSquare;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.dotsIsSquare = dotsIsSquare;
}

-(void)setTextFont:(UIFont *)textFont{
    if (_textFont == textFont) return;
    _textFont = textFont;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.textFont = textFont;
}

-(void)setTextColor:(UIColor *)textColor{
    if (_textColor == textColor) return;
    _textColor = textColor;
    MSPageControl *pageControl = (MSPageControl *)_pageControl;
    pageControl.textColor = textColor;
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

    MSPageControl *pageControl = [[MSPageControl alloc] init];
    pageControl.numberOfPages = self.imagePathsGroup.count;
    pageControl.userInteractionEnabled = NO;
    pageControl.currentPage = indexOnPageControl;
    pageControl.spacingBetweenDots = self.spacingBetweenDots;
    pageControl.currentWidthMultiple = self.currentWidthMultiple;
    pageControl.pageControlStyle = self.pageControlStyle;
    pageControl.pageControlAnimation = self.pageControlAnimation;
    
    pageControl.dotsIsSquare = self.dotsIsSquare;
    pageControl.dotColor = self.pageDotColor;
    pageControl.currentDotColor = self.currentPageDotColor;
    pageControl.dotBorderWidth = self.dotBorderWidth;
    pageControl.currentDotBorderWidth = self.currentDotBorderWidth;

    pageControl.dotBorderColor = self.dotBorderColor;
    pageControl.currentDotBorderColor = self.currentDotBorderColor;

    pageControl.textFont = self.textFont;
    pageControl.textColor = self.textColor;
    
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
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
    if (_mainView.ms_width == 0 || _mainView.ms_height == 0) {
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

+ (void)clearCache{
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
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
    if (!(self.pageDotImage && self.currentPageDotImage && CGSizeEqualToSize(kCycleScrollViewInitialPageControlDotSize, self.pageControlDotSize))) {
        _pageControl.pageDotSize = self.pageControlDotSize;
    }
    size = [_pageControl sizeForNumberOfPages:self.imagePathsGroup.count];
  
    CGFloat x = (self.ms_width - size.width) * 0.5;
    if (self.pageControlAliment == kMSPageContolAlimentRight) {
        x = self.mainView.ms_width - size.width - 10;
    }
    CGFloat y = self.mainView.ms_height - size.height - 10;
    [self.pageControl sizeToFit];

//    if ([self.pageControl isKindOfClass:[MSPageControl class]]) {
//        MSPageControl *pageControl = (MSPageControl *)_pageControl;
//    }

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
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[imagePath ms_UTF8String]] placeholderImage:self.placeholderImage];
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
    _pageControl.currentPage = indexOnPageControl;

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
    
    int scrollIndex = (int)(_totalItemsCount * 0.5 + index);
    if (!_infiniteLoop) {
        scrollIndex = (int)index;
    }
    
    [self scrollToIndex:scrollIndex];
    
    if (self.autoScroll) {
        [self setupTimer];
    }
}

@end


@implementation NSString (MSExtentions)
//处理URL已转义的%等符号时,又会再次转义而导致错误
-(NSString *)ms_UTF8String {
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString: @"!$&'()*+,-./:;=?@_~%#[]"];
    return [self stringByAddingPercentEncodingWithAllowedCharacters: allowed];
}

@end
