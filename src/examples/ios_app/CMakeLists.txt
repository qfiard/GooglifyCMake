ios_app(TestApp)
add_local_file(TestApp Info.plist /)
add_local_file(TestApp main TestApp)

objc_library(app_delegate AppDelegate.h AppDelegate.m)
link_framework(app_delegate UIKit)

objc_binary(main main.m)
link(main :app_delegate)
link_framework(main Foundation UIKit)
