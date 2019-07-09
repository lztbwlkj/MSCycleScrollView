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

@interface ViewController () <MSCycleScrollViewDelegate>

@end

@implementation ViewController
{
    NSArray *_imagesURLStrings;
    MSCycleScrollView *_customCellScrollViewDemo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *demoContainerView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    demoContainerView.contentSize = CGSizeMake(self.view.frame.size.width, 1500);
    [self.view addSubview:demoContainerView];
    
    self.title = @"轮播Demo";
    
    
    // 情景一：采用本地图片实现
    NSArray *imageNames = @[@"timg5.jpeg",
                            @"timg6.jpeg",
                            @"timg7.jpeg",
                            @"timg8.jpeg",
                            @"timg9.jpeg",// 本地图片请填写全名
                            ];
    // 情景二：采用网络图片实现
    NSArray *imagesURLStrings = @[
                                  @"https://weiliicimg9.pstatp.com/weili/l/378983035183038486.webp",
                                  @"https://icweiliimg1.pstatp.com/weili/l/446936813792919821.webp",
                                  @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562577371120&di=6b68ad41c6d78af64a3845833def95d8&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F203fb80e7bec54e7f0e0839fb7389b504fc26a27.jpg",
                                  @"https://weiliicimg9.pstatp.com/weili/l/454268675154510337.webp",
                                  ];
    _imagesURLStrings = imagesURLStrings;
    
    // 情景三：图片配文字
    NSArray *titles = @[
                        @"disableScrollGesture可以设置禁止拖动",
                        @"感谢您的支持，如果下载的",
                        @"如果代码在使用过程中出现问题",
                        @"您可以发邮件到lztbwlkj@gmail.com",
                        @"或者您可以issues"
                        ];
    
    CGFloat w = self.view.bounds.size.width;
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图1 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 本地加载 --- 创建不带标题的图片轮播器
    MSCycleScrollView *cycleScrollView = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 0, w, 180) InfiniteLoop:YES locationImageNames:imageNames];
    cycleScrollView.delegate = self;
    [demoContainerView addSubview:cycleScrollView];
        //         --- 轮播时间间隔，默认1.0秒，可自定义
    //cycleScrollView.autoScrollTimeInterval = 4.0;
    cycleScrollView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    

    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图2 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // 本地加载 --- 创建不带标题的图片轮播器
    MSCycleScrollView *cycleScrollView5 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 190, w, 180) InfiniteLoop:YES locationImageNames:imageNames];
    cycleScrollView5.delegate = self;
    cycleScrollView5.pageDotColor = [UIColor blueColor];
    cycleScrollView5.currentPageDotColor = [UIColor yellowColor];
    cycleScrollView5.dotsIsSquare = YES;
    cycleScrollView5.currentWidthMultiple = 3;
//    cycleScrollView5.pageControlDotSize = CGSizeMake(6, 5);
    [demoContainerView addSubview:cycleScrollView5];
    //指定Index
    [cycleScrollView5 makeScrollViewScrollToIndex:2];
    
    // 网络加载 --- 创建带标题的图片轮播器
    MSCycleScrollView *cycleScrollView2 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 370, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];

    cycleScrollView2.pageControlAliment = kMSPageContolAlimentRight;
    cycleScrollView2.titles = titles;
//    cycleScrollView2.spacingBetweenDots = 20;//jian
    cycleScrollView2.currentWidthMultiple = 3;

    cycleScrollView2.pageControlDotSize = CGSizeMake(6, 6);
    cycleScrollView2.pageControlAnimation = MSPageControlAnimationSystem;
    [demoContainerView addSubview:cycleScrollView2];
    
    // --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cycleScrollView2.imageUrls = imagesURLStrings;
    });
    
    /*
     block监听点击方式
     cycleScrollView2.clickItemOperationBlock = ^(NSInteger index) {
     NSLog(@">>>>>  %ld", (long)index);
     };
     */
    
    // >>>>>>>>>>>>>>>> demo轮播图3 >>>>>>>>>>>>>>>>
    
    // 网络加载 --- 创建自定义图片的pageControlDot的图片轮播器
    MSCycleScrollView *cycleScrollView3 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 560, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    //如果设置了 currentPageDotImage 和 pageDotImage 则pageControlDotSize将失效
    cycleScrollView3.currentPageDotImage = [UIImage imageNamed:@"Ktv_ic_share_qq"];
    cycleScrollView3.pageDotImage = [UIImage imageNamed:@"Ktv_ic_share_weixin"];
    cycleScrollView3.imageUrls = imagesURLStrings;
    [demoContainerView addSubview:cycleScrollView3];
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图4 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 网络加载 --- 创建只上下滚动展示文字的轮播器
    // 由于模拟器的渲染问题，如果发现轮播时有一条线不必处理，模拟器放大到100%或者真机调试是不会出现那条线的
    MSCycleScrollView *cycleScrollView4 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 750, w, 40) delegate:self placeholderImage:nil];
    cycleScrollView4.scrollDirection = UICollectionViewScrollDirectionVertical;
    cycleScrollView4.onlyDisplayText = YES;
    cycleScrollView4.autoScrollTimeInterval = 3;

    NSMutableArray *titlesArray = [NSMutableArray new];
    [titlesArray addObject:@"纯文字上下滚动轮播-- demo轮播图4,纯文字上下滚动"];
    [titlesArray addObject:@"纯文字上下滚动轮播 -- demo轮播图4"];
//    [titlesArray addObjectsFromArray:titles];
    cycleScrollView4.titles = [titlesArray copy];
    [cycleScrollView4 disableScrollGesture];
    [demoContainerView addSubview:cycleScrollView4];
    

    MSCycleScrollView *cycleScrollView6 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 805, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView6.imageUrls = imagesURLStrings;
    cycleScrollView6.pageControlStyle = MSPageControlStyleNumber;
    cycleScrollView6.pageControlDotSize = CGSizeMake(15, 15);
    cycleScrollView6.pageControlBottomOffset = -5;
    cycleScrollView6.pageDotColor = [UIColor redColor];
    cycleScrollView6.currentPageDotColor = [UIColor blueColor];
    cycleScrollView6.textFont =[UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    cycleScrollView6.textColor = [UIColor whiteColor];
    cycleScrollView6.dotsIsSquare = YES;
    cycleScrollView6.spacingBetweenDots = 20;
    [demoContainerView addSubview:cycleScrollView6];
    
    
    MSCycleScrollView *cycleScrollView7 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, CGRectGetMaxY(cycleScrollView6.frame) + 10, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView7.imageUrls = imagesURLStrings;
    cycleScrollView7.pageDotColor = [UIColor lightGrayColor];
    cycleScrollView7.currentPageDotColor = [UIColor whiteColor];
    cycleScrollView7.dotBorderWidth = 1;
    cycleScrollView7.dotBorderColor = [UIColor whiteColor];
//    cycleScrollView7.currentDotBorderColor =[UIColor whiteColor];
//    cycleScrollView7.currentDotBorderWidth = 1;
    cycleScrollView7.dotsIsSquare = YES;
    cycleScrollView7.pageControlDotSize = CGSizeMake(12, 12);
    [demoContainerView addSubview:cycleScrollView7];
    
    
    //         --- 轮播时间间隔，默认1.0秒，可自定义
    //cycleScrollView.autoScrollTimeInterval = 4.0;
    
    // >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图5 自定义cell的轮播图 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 如果要实现自定义cell的轮播图，必须先实现customCollectionViewCellClassForCycleScrollView:和setupCustomCell:forIndex:代理方法
//
//    _customCellScrollViewDemo = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 790, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    _customCellScrollViewDemo.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
//    _customCellScrollViewDemo.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
//    _customCellScrollViewDemo.imageUrls = imagesURLStrings;
//
//    [demoContainerView addSubview:_customCellScrollViewDemo];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 如果你发现你的CycleScrollview会在viewWillAppear时图片卡在中间位置，你可以调用此方法调整图片位置
    //    [你的CycleScrollview adjustWhenControllerViewWillAppera];
}


#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(MSCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
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

