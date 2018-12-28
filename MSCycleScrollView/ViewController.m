//
//  ViewController.m
//  MSCycleScrollView
//
//  Created by TuBo on 2018/12/28.
//  Copyright © 2018 turBur. All rights reserved.
//

#import "ViewController.h"
#import "MSCycleScrollView.h"
#import "CustomCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "MSExampleDotView.h"

@interface ViewController () <MSCycleScrollViewDelegate>

@end

@implementation ViewController
{
    NSArray *_imagesURLStrings;
    MSCycleScrollView *_customCellScrollViewDemo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.99];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"005.jpg"]];
    backgroundView.frame = self.view.bounds;
    [self.view addSubview:backgroundView];
    
    UIScrollView *demoContainerView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    demoContainerView.contentSize = CGSizeMake(self.view.frame.size.width, 1200);
    [self.view addSubview:demoContainerView];
    
    self.title = @"轮播Demo";
    
    
    // 情景一：采用本地图片实现
    NSArray *imageNames = @[@"h1.jpg",
                            @"h2.jpg",
                            @"h3.jpg",
                            @"h6.jpg",
                            @"h7" // 本地图片请填写全名
                            ];
    
    // 情景二：采用网络图片实现
    NSArray *imagesURLStrings = @[
                                  @"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                                  @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                                  @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
                                  ];
    _imagesURLStrings = imagesURLStrings;
    
    // 情景三：图片配文字
    NSArray *titles = @[
                        @"disableScrollGesture可以设置禁止拖动",
                        @"感谢您的支持，如果下载的",
                        @"如果代码在使用过程中出现问题",
                        @"您可以发邮件到lztbwlkj@gmail.com"
                        @"或者您可以ission"
                        ];
    
    CGFloat w = self.view.bounds.size.width;
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图1 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 本地加载 --- 创建不带标题的图片轮播器
    MSCycleScrollView *cycleScrollView = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 64, w, 180) InfiniteLoop:YES locationImageNames:imageNames];
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlStyle = kMSPageContolStyleAnimated;
    [demoContainerView addSubview:cycleScrollView];
        //         --- 轮播时间间隔，默认1.0秒，可自定义
    //cycleScrollView.autoScrollTimeInterval = 4.0;
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图2 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // 网络加载 --- 创建带标题的图片轮播器
    MSCycleScrollView *cycleScrollView2 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 280, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView2.pageControlStyle = kMSPageContolStyleCustomer;
    cycleScrollView2.pageControlAliment = kMSPageContolAlimentRight;
    cycleScrollView2.titles = titles;
    cycleScrollView2.dotViewClass = [MSExampleDotView class];
    cycleScrollView2.pageControlDotSize = CGSizeMake(6, 6);
    cycleScrollView2.spacingBetweenDots = 10;

    //如果自定义了pageControl的样式则部分pageControl将失效
//    _customCellScrollViewDemo.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
//    _customCellScrollViewDemo.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    [demoContainerView addSubview:cycleScrollView2];
    
    //         --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cycleScrollView2.imageUrls = imagesURLStrings;
    });
    
    /*
     block监听点击方式
     
     cycleScrollView2.clickItemOperationBlock = ^(NSInteger index) {
     NSLog(@">>>>>  %ld", (long)index);
     };
     
     */
    
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图3 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 网络加载 --- 创建自定义图片的pageControlDot的图片轮播器
    MSCycleScrollView *cycleScrollView3 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 500, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView3.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
    cycleScrollView3.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    cycleScrollView3.imageUrls = imagesURLStrings;
    
    [demoContainerView addSubview:cycleScrollView3];
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图4 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 网络加载 --- 创建只上下滚动展示文字的轮播器
    // 由于模拟器的渲染问题，如果发现轮播时有一条线不必处理，模拟器放大到100%或者真机调试是不会出现那条线的
    MSCycleScrollView *cycleScrollView4 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 750, w, 40) delegate:self placeholderImage:nil];
    cycleScrollView4.scrollDirection = UICollectionViewScrollDirectionVertical;
    cycleScrollView4.onlyDisplayText = YES;
    
    NSMutableArray *titlesArray = [NSMutableArray new];
    [titlesArray addObject:@"纯文字上下滚动轮播"];
    [titlesArray addObject:@"纯文字上下滚动轮播 -- demo轮播图4"];
    [titlesArray addObjectsFromArray:titles];
    cycleScrollView4.titles = [titlesArray copy];
    [cycleScrollView4 disableScrollGesture];
    
    [demoContainerView addSubview:cycleScrollView4];
    
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图5 自定义cell的轮播图 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 如果要实现自定义cell的轮播图，必须先实现customCollectionViewCellClassForCycleScrollView:和setupCustomCell:forIndex:代理方法
    
    _customCellScrollViewDemo = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 820, w, 120) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    _customCellScrollViewDemo.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
    _customCellScrollViewDemo.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    _customCellScrollViewDemo.imageUrls = imagesURLStrings;
    
    [demoContainerView addSubview:_customCellScrollViewDemo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 如果你发现你的CycleScrollview会在viewWillAppear时图片卡在中间位置，你可以调用此方法调整图片位置
    //    [你的CycleScrollview adjustWhenControllerViewWillAppera];
}


#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(MSCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", (long)index);
    
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}


/*
 
 // 滚动到第几张图回调
 - (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
 {
 NSLog(@">>>>>> 滚动到第%ld张图", (long)index);
 }
 
 */
























// 不需要自定义轮播cell的请忽略下面的代理方法

// 如果要实现自定义cell的轮播图，必须先实现customCollectionViewCellClassForCycleScrollView:和setupCustomCell:forIndex:代理方法

- (Class)customCollectionViewCellClassForCycleScrollView:(MSCycleScrollView *)view
{
    if (view != _customCellScrollViewDemo) {
        return nil;
    }
    return [CustomCollectionViewCell class];
}

- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(MSCycleScrollView *)view
{
    CustomCollectionViewCell *myCell = (CustomCollectionViewCell *)cell;
    [myCell.imageView sd_setImageWithURL:_imagesURLStrings[index]];
}

@end

