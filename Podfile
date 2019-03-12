use_frameworks! 

# MacOS
target 'Composite' do
  platform :osx, '10.13'

  pod 'Sparkle' # TODO: https://gist.github.com/huangyq23/668e6d6fcccf714e802a
  #pod 'SwiftFSWatcher'
  
  # CotEditor dependencies
  pod 'Differ', '~> 1.3.0'
  pod 'YAML-Framework', :git => 'https://github.com/coteditor/YAML.framework.git', :branch => 'coteditor-mod'
  pod 'WFColorCode', :git => 'https://github.com/1024jp/WFColorCode.git', :branch => 'master'

  target 'CompositeTests' do
    inherit! :search_paths
    # Pods for testing
  end
end
