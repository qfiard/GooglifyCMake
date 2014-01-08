package examples.a_package;

public class Main {
  public static void main(String[] args) {
    MyLib.HelloWorld();
    examples.other_package.MyLib.HelloWorld();
  }
}
