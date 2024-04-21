import 'dart:math';

class Utility {

  List<int> generateRandomNumbersInRangeWithoutRepeats(int min, int max, int count) {
    if (count > (max - min + 1)) {
      throw ArgumentError('Count must be less than or equal to the range of numbers');
    }

    Random random = Random();
    Set<int> generatedNumbers = {};

    while (generatedNumbers.length < count) {
      int randomNumber = min + random.nextInt(max - min + 1);
      generatedNumbers.add(randomNumber);
    }

    return generatedNumbers.toList();
  }

}