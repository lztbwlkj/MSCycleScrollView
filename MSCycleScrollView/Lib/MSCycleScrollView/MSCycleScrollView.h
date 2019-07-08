//
//  MSCycleScrollView.h
//  MSCycleScrollView
//
//  Created by TuBo on 2018/12/28.
//  Copyright © 2018 turBur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPageControl.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    kMSPageContolAlimentRight,
    kMSPageContolAlimentCenter
} kMSPageContolAliment;


@class MSCycleScrollView;

@protocol MSCycleScrollViewDelegate <NSObject>

@optional


/**
 点击图片回调

 @param cycleScrollView MSCycleScrollView
 @param index ScrollView当前页面的下标
 */
- (void)cycleScrollView:(MSCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;


/**
 图片滚动回调

 @param cycleScrollView MSCycleScrollView
 @param index ScrollView当前页面的下标
 */
- (void)cycleScrollView:(MSCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;


#pragma mark ======= 轮播自定义cell(不需要自定义轮播cell的请略过以下两个的代理方法) ==========

/** 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的class。 */
- (Class)customCellClassForCycleScrollView:(MSCycleScrollView *)view;


/**
 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的Nib

 @param view MSCycleScrollView
 @return nib对象
 */
- (UINib *)customCellNibForCycleScrollView:(MSCycleScrollView *)view;

/**
 如果你自定义了cell样式，请在实现此代理方法为你的cell填充数据以及其它一系列设置

 @param cell 自定义的cell
 @param index cell的下标
 @param view MSCycleScrollView
 */
- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(MSCycleScrollView *)view;

@end
@interface MSCycleScrollView : UIView

/**
 网络图片 url string 数组
 */
@property (nonatomic, strong) NSArray *imageUrls;

/**
 每张图片对应要显示的文字数组
 */
@property (nonatomic, strong) NSArray *titles;

/**
 本地图片数组
 */
@property (nonatomic, strong) NSArray *locationImageNames;

/**
 自动滚动间隔时间,默认3s
 */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;


/**
 是否无限循环,默认Yes
 */
@property (nonatomic,assign) BOOL infiniteLoop;

/**
 是否自动滚动,默认Yes
 */
@property (nonatomic,assign) BOOL autoScroll;

/**
 图片滚动方向，默认为水平滚动
 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/**
 block方式监听点击
 */
@property (nonatomic, copy) void (^clickItemOperationBlock)(NSInteger currentIndex);

/**
 block方式监听滚动
 */
@property (nonatomic, copy) void (^itemDidScrollOperationBlock)(NSInteger currentIndex);

/**
 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill
 */
@property (nonatomic, assign) UIViewContentMode bannerImageViewContentMode;

/**
 占位图，用于网络未加载到图片时
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 只展示文字轮播
 */
@property (nonatomic, assign) BOOL onlyDisplayText;

/**
  分页控件位置
 */
@property (nonatomic, assign) kMSPageContolAliment pageControlAliment;

/**
 MSPageControl的过渡动画 目前只支持两种样式 其他样式需要自定义（自定义样式暂未开放）
 */
@property(nonatomic,assign) MSPageControlAnimation pageControlAnimation;
#pragma mark ================== PageControl属性设置 ==================

/**
 MSPageControl的样式 目前只支持两种样式
 */
@property(nonatomic,assign) MSPageControlStyle pageControlStyle;
/**
 是否显示分页控件
 */
@property (nonatomic, assign) BOOL showPageControl;

/**
 是否在只有一张图时隐藏pagecontrol，默认为YES
 */
@property(nonatomic) BOOL hidesForSinglePage;

/**
 分页控件距离轮播图的底部间距（在默认间距基础上）的偏移量
 */
@property (nonatomic, assign) CGFloat pageControlBottomOffset;

/**
 相邻两个小圆点间的间隔大小 Default is 8.
 */
@property (nonatomic,assign) CGFloat spacingBetweenDots;

/**
 分页控件距离轮播图的右边间距（在默认间距基础上）的偏移量
 */
@property (nonatomic, assign) CGFloat pageControlRightOffset;

/**
 * 分页控件小圆标大小
 * 如果设置了 currentPageDotImage 和 pageDotImage 则pageControlDotSize将失效
 */
@property (nonatomic, assign) CGSize pageControlDotSize;

/**
 当前分页控件小圆标颜色
 */
@property (nonatomic, strong) UIColor *currentPageDotColor;

/**
 其他分页控件小圆标颜色
 */
@property (nonatomic, strong) UIColor *pageDotColor;

/**
 当前分页控件小圆标图片
 */
@property (nonatomic, strong) UIImage *currentPageDotImage;

/**
 其他分页控件小圆标图片
 */
@property (nonatomic, strong) UIImage *pageDotImage;

#pragma mark - 新增属性
/**
 是否是方形点 默认NO 显示圆形
 */
@property(nonatomic, assign) BOOL dotsIsSquare;

/**
 当前选中点宽度与未选中点的宽度的倍数 默认是1
 * 计算方法 pageDotSize.width = pageDotSize.width * currentWidthMultiple；
 */
@property(nonatomic, assign) CGFloat currentWidthMultiple;

/**
 未选中点的layerColor
 */
@property(nonatomic, strong) UIColor *dotBorderColor;

/**
 选中点的layerColor
 */
@property(nonatomic, strong) UIColor *currentDotBorderColor;

/**
 未选中点的layer宽度
 */
@property(nonatomic, assign) CGFloat dotBorderWidth;

/**
 选中点的layer宽度
 */
@property(nonatomic, assign) CGFloat currentDotBorderWidth;

/**
  轮播文字label对齐方式
 */
@property (nonatomic, assign) NSTextAlignment titleLabelTextAlignment;


/**
 pageControlAnimation为MSPageControlStyleNumber时字体设置
 */
@property(nonatomic,strong) UIFont *textFont;

/**
 pageControlAnimation为MSPageControlStyleNumber时文本颜色设置
 */
@property(nonatomic,strong) UIColor *textColor;


@property (nonatomic, weak) id<MSCycleScrollViewDelegate> delegate;
#pragma mark ================== 显示标题Label的属性 ==================
/**
 轮播文字label高度
 */
@property (nonatomic, assign) CGFloat titleLabelHeight;

/**
 轮播文字label字体颜色
 */
@property (nonatomic, strong) UIColor *titleLabelTextColor;

/**
 轮播文字label字体大小
 */
@property (nonatomic, strong) UIFont  *titleLabelTextFont;

/**
 轮播文字label背景颜色
 */
@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;

#pragma mark ================== 初始化方式 ==================

/** */
/**
  初始轮播图（推荐使用）

 @param frame frame
 @param delegate 代理
 @param placeholderImage 默认显示图片
 @return MSCycleScrollView
 */
+(instancetype)cycleViewWithFrame:(CGRect)frame delegate:(id<MSCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage;

/**
 本地图片轮播初始化方式2

 @param frame frame
 @param infiniteLoop 是否无限循环
 @param imageNames 本地图片名称
 @return MSCycleScrollView
 */
+ (instancetype)cycleViewWithFrame:(CGRect)frame InfiniteLoop:(BOOL)infiniteLoop locationImageNames:(NSArray *)imageNames;


/**
 可以调用此方法手动控制滚动到哪一个index

 @param index 指定对应的index
 */
- (void)makeScrollViewScrollToIndex:(NSInteger)index;

/**
 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法
 */
- (void)adjustWhenControllerViewWillAppera;

/**
 滚动手势禁用（文字轮播较实用）
 */
- (void)disableScrollGesture;

#pragma mark ================== 清除缓存 ==================

/**
 清除图片缓存
 */
+ (void)clearCache;

@end


@interface NSString (MSExtentions)
-(NSString *)ms_UTF8String;
@end


NS_ASSUME_NONNULL_END
