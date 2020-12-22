Pod::Spec.new do |s|
  s.name             = 'CollectionViewWaterfallLayout'
  s.version          = '0.5.0'
  s.summary          = 'Pinterest inspired layout for UICollectionViews written in Swift'
  s.description      = <<-DESC
                        Custom UICollectionView layout inspired by Pinterest. It can layout multiple columns of items with different heights to create dynamic flowing cells.
                       DESC
  s.homepage         = 'https://github.com/ecerney/CollectionViewWaterfallLayout'
  s.screenshots      = 'https://raw.githubusercontent.com/ecerney/CollectionViewWaterfallLayout/master/Screenshots/RealWorldExample.png', 'https://raw.githubusercontent.com/ecerney/CollectionViewWaterfallLayout/master/Screenshots/DemoExample.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eric Cerney' => 'ecerney@gmail.com' }
  s.source           = { :git => 'https://github.com/ecerney/CollectionViewWaterfallLayout.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ecerney'
  s.ios.deployment_target = '8.0'
  s.swift_versions = '5.0'
  s.source_files = 'Sources/CollectionViewWaterfallLayout/CollectionViewWaterfallLayout.swift'
  s.frameworks = 'UIKit'
end
