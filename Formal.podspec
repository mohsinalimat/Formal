Pod::Spec.new do |s|
  s.name             = "Formal"
  s.version          = "1.0.0"
  s.summary          = "A UITableView form builder."
  s.homepage         = "https://github.com/Meniny/Formal"
  s.license          = 'MIT'
  s.author           = { "Elias Abel" => "Meniny@qq.com" }
  s.source           = { :git => "https://github.com/Meniny/Formal.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Formal/*.*'
  s.module_name = 'Formal'
  s.public_header_files = 'Formal/*.h'
  s.frameworks = 'Foundation', 'UIKit'
end
