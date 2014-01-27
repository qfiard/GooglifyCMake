ios_app(TestApp)
add_local_file(TestApp Info.plist /)
add_local_file(TestApp main TestApp)

objc_binary(main main.mm)
link(main Foundation UIKit examples.a_package.my_lib)
