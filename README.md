# MSCycleScrollView
一款在SDCycleScrollView的基础上对PageControl的样式进行扩展的轮播图,可根据自己需求自定义PageControl的样式（包括小圆点+横线的样式）、颜色、图片、边框颜色、边框宽度、方形点或者圆形点、以及各点之间的间距大小等，定制样式多样化！欢迎大家使用,

---
#### 最近工作比较忙，没有更新REAMD.md文件效果图，具体效果还请下载Demo运行查看

#### 代码参考于一款优秀的轮播图框架：[SDCycleScrollView](https://github.com/gsdios/SDCycleScrollView.git)。也十分感谢[高少东(gsdios)](https://github.com/gsdios)作者。

### 效果图展示:
###### (请原谅电脑太卡，不能为大家上传gif图片难受！！！)
<table>
<tr>
<th>默认样式</th>
<th>默认动画样式</th>
</tr>
<tr>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/IMG_0572.jpg" width="320" height="180"></td>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/IMG_0568.jpg" width="320" height="180"></td>
</tr>
<tr>
<th>自定义pageControl样式</th>
<th>自定义图片样式 </th>
</tr>
<tr>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/IMG_0569.jpg" width="320" height="180"></td>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/IMG_0570.jpg" width="320" height="180"></td>
</tr> 
<tr>
<th>只显示文本样式</th>
</tr>
<tr>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/IMG_0571.jpg" width="350" height="100"></td>
</tr> 
</table>

### 更新记录：
2018.12.29 -- v0.0.1:提交0.0.1版本，添加PageControl的自定义属性;


## 集成方式

### 一、Cocoapods集成

```objc

  pod 'MSCycleScrollView','~>0.0.1'

```
### 一、手动集成
1. 下载Demo，将Demo中的MSCycleScrollView文件夹拖入所需工程中
2. 在需要的文件下

```objc
    #import "MSCycleScrollView.h"
```

## 使用方式（支持StoryBoard或者Nib）
使用方法与[SDCycleScrollView](https://github.com/gsdios/SDCycleScrollView.git)类似，或者可下载Demo查看，这里就不多赘述。


## 注意事项
#### 1、关于PageControl的样式自定义需要创建UIView继承 "MSAbstractDotView" 实现,具体方式可查看Demo中的"MSExampleDotView"类

```objc
- (void)changeActivityState:(BOOL)active dotView:(nonnull MSAbstractDotView *)dotView pageDotSize:(CGSize)pageDotSize;
```

#### 2、在使用了自定义PageControl的自定义样式后，部分PageControl的属性将失效，比如颜色，自定义图片等；


## 你的Star是我更新的动力，使用过程如果有什么问题或者有什么新的建议，可以[issues](https://github.com/lztbwlkj/MSCycleScrollView/issues/new),我会及时回复大家！
