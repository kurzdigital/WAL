#
#  Be sure to run `pod spec lint WAL.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "WAL"
  s.version      = "0.0.1"
  s.summary      = "WebRTC Abstraction Layer"
  s.description  = "Easy use of WebRTC to build a VoIP app"
  s.homepage     = "https://kurzdigital.com"
  s.license = { :type => 'BSD'} 
  s.author             = { "Christian Braun" => "christian.braun@kurzdigital.com" }
  s.social_media_url   = "http://twitter.com/NorbiBraun"
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://git.kurzdigital.com/cbr/WAL", :tag => s.version.to_s}

  s.source_files = "WAL"
  s.requires_arc = true

  s.swift_version = "4.1"
  s.dependency "WebRTC", -> "63.11"
end
