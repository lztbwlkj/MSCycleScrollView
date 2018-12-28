

Pod::Spec.new do |spec|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  These will help people to find your library, and whilst it
#  can feel like a chore to fill in it's definitely to your advantage. The
#  summary should be tweet-length, and the description more in depth.
#

spec.name         = "MSCycleScrollView"
spec.version      = "0.0.1"
spec.summary      = "参考SDCycleScrollView，添加PageControl的自定义属性，可更具自己需求自定义PageControl的样式（包括小圆点+横线的样式）、颜色、动画，以及各点之间的间距大小等"

spec.description  = <<-DESC
参考SDCycleScrollView，添加PageControl的自定义属性，可更具自己需求自定义PageControl的样式（包括小圆点+横线的样式）、颜色、动画，以及各点之间的间距大小等
DESC

spec.homepage     = "https://github.com/lztbwlkj/MSCycleScrollView.git"
spec.license          = { :type => 'MIT', :file => 'LICENSE' }
spec.author             = { "lztbwlkj" => "lztbwlkj@gmail.com" }

spec.platform     = :ios,"8.0"

spec.source       = { :git => "https://github.com/lztbwlkj/MSCycleScrollView.git", :tag => "#{spec.version}" }


spec.source_files  = "MSCycleScrollView/Lib/MSCycleScrollView/**/*"

spec.requires_arc = true

spec.dependency 'SDWebImage', '~> 4.0.0'

end
