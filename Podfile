project 'clean-redux/clean-redux.xcodeproj/'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.2'

def shared_pods
  # Utility
  pod 'R.swift'

  # Redux
  pod 'ReSwift'
  pod 'ReSwiftRouter'
  pod 'ReRxSwift'
  
  # Feedback
  pod 'RxFeedback'

  # Reactive
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxLens', :path => '~/Documents/playgrounds/RxLens/'
  pod 'Action'
  pod 'ReactorKit'
  
end

target 'clean-redux' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for clean-redux
  shared_pods

  target 'clean-reduxTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
