

Pod::Spec.new do |spec|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  These will help people to find your library, and whilst it
#  can feel like a chore to fill in it's definitely to your advantage. The
#  summary should be tweet-length, and the description more in depth.
#

spec.name         = "MSCycleScrollView"
spec.version      = "0.0.3"
spec.summary      = "一款在SDCycleScrollView的基础上对PageControl的样式进行扩展的轮播图"
spec.description  = <<-DESC
                 一款在SDCycleScrollView的基础上对PageControl的样式进行扩展的轮播图,可根据自己需求自定义PageControl的样式（包括小圆点+横线的样式）、颜色、图片、边框颜色、边框宽度、方形点或者圆形点、以及各点之间的间距大小等，定制样式多样化！欢迎大家使用
DESC

spec.homepage     = "https://github.com/lztbwlkj/MSCycleScrollView"
spec.license          = { :type => 'MIT', :file => 'LICENSE' }
spec.author             = { "lztbwlkj" => "lztbwlkj@gmail.com" }
spec.platform     = :ios,"9.0"
spec.source       = { :git => "https://github.com/lztbwlkj/MSCycleScrollView.git", :tag => "#{spec.version}" }
spec.source_files  = "MSCycleScrollView/Lib/MSCycleScrollView/**/*"
spec.requires_arc = true
spec.dependency 'SDWebImage'

end
