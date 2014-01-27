objc_binary(main main.mm)
link(main examples.a_package.my_lib)
link_framework(main Foundation UIKit)

ios_app(TestApp)
add_local_file(TestApp main TestApp)
add_local_file(TestApp Info.plist /)
