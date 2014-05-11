#import <stdio.h>
#import <Foundation/NSObject.h>

@interface Fraction : NSObject {
  int numerator;
  int denominator;
}

- (void)print;
- (void)setNumerator:(int)n;
- (void)setDenominator:(int)d;
- (int)numerator;
- (int)denominator;
@end

@implementation Fraction
- (void)print {
  printf("%i/%i", numerator, denominator);
}

- (void)setNumerator:(int)n {
  numerator = n;
}

- (void)setDenominator:(int)d {
  denominator = d;
}

- (int)denominator {
  return denominator;
}

- (int)numerator {
  return numerator;
}
@end

int main(int argc, char **argv) {
  // create a new instance
  Fraction *frac = [[Fraction alloc] init];

  // set the values
  [frac setNumerator:1];
  [frac setDenominator:3];

  // print it
  printf("The fraction is: ");
  [frac print];
  printf("\n");

  return 0;
}
