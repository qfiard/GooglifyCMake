ios_app(TestApp)
add_local_file(TestApp Info.plist /)
add_local_file(TestApp main TestApp)

objc_binary(main main.mm)
link_framework(main Foundation UIKit)
