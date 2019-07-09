# MSCycleScrollView
一款在SDCycleScrollView的基础上对PageControl的样式进行扩展的轮播图,可根据自己需求自定义PageControl的样式（包括小圆点+横线的样式）、颜色、图片、边框颜色、边框宽度、方形点或者圆形点、以及各点之间的间距大小等，定制样式多样化！欢迎大家使用,

---

#### 代码参考于一款优秀的轮播图框架：[SDCycleScrollView](https://github.com/gsdios/SDCycleScrollView.git)! 感谢[高少东(gsdios)](https://github.com/gsdios)作者。

### 效果图展示:

<table>
<tr>
<th>默认样式</th>
<th>带边框圆形点样式</th>
<th>带边框方形点样式</th>
</tr>
<tr>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/systemPoint.gif" width="330" height="180"></td>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/borderPoint.gif" width="330" height="180"></td>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/dotsIsSquare.gif" width="330" height="180"></td>
</tr>
</tr>

<tr>
<th>横线+小圆点样式</th>
<th>横线+小方点样式</th>
<th>自定义图片样式</th>
</tr>
<tr>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/hengAndpoint.gif" width="330" height="180"></td>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/hengPoint2.gif" width="330" height="180"></td>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/imageDots.gif" width="330" height="180"></td>
</tr> 
<tr>
<th>数字文本样式</th>
<th>只显示文本样式</th>
</tr>
<tr>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/numberPoint.gif" width="330" height="180"></td>
<td><img src="https://github.com/lztbwlkj/MSCycleScrollView/blob/master/images/text.gif" width="300" height="160"></td>
</tr> 
</table>

### 更新记录：
2019.07.09 -- v0.0.4：Pod添加MSPageControl的依赖库；
2019.07.08 -- v0.0.3：修复调用[makeScrollViewScrollToIndex:]方法出现异常问题；
2019.07.04 -- v0.0.2：删除部分无用属性，重新调整PageControl
,增加更多PageControl的自定义属性；
2018.12.29 -- v0.0.1:提交0.0.1版本，添加PageControl的自定义属性；


## 集成方式

### 一、Cocoapods集成

```objc

  pod 'MSCycleScrollView','~>0.0.2'

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

#### 1、在使用了PageControl的自定义图片样式后，pageDotsSize属性将失效；


## 如果觉得好用麻烦动个手指给个Star，你的Star是我更新的动力，使用过程如果有什么问题可以[issues](https://github.com/lztbwlkj/MSCycleScrollView/issues/new),我会及时回复大家！
