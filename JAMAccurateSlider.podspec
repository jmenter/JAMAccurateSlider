Pod::Spec.new do |s|
  s.name         = "JAMAccurateSlider"
  s.version      = "1.0.0"
  s.summary      = "A UISlider subclass that enables more accurate value selection."

  s.description  = <<-DESC
                   A UISlider subclass that enables more accurate value selection.
                   DESC
  s.homepage     = "https://github.com/jmenter/JAMAccurateSlider"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Jeff Menter" => "jmenter@gmail.com" }
  s.social_media_url = "http://twitter.com/jmenter"
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/jmenter/JAMAccurateSlider.git", :tag => s.version.to_s }
  s.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  s.requires_arc = true

end
