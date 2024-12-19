import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:test/test.dart';

void main() {
  group('simplifyPath', () {
    test('should simplify a path with redundant points', () {
      final path = [
        (1, 2),
        (1, 3),
        (1, 4),
        (1, 5),
      ];
      final expected = [
        (1, 2),
        (1, 5),
      ];

      final result = AStar.simplifyPath(path);
      expect(result, equals(expected));
    });

    test('should return an empty list for an empty path', () {
      final path = <(int, int)>[];
      final expected = <(int, int)>[];

      final result = AStar.simplifyPath(path);
      expect(result, equals(expected));
    });
  });

  group('_simplifyDirection', () {
    test('should simplify a path in the X direction', () {
      final path = [
        (1, 2),
        (1, 3),
        (1, 4),
        (1, 5),
      ];
      final expected = [
        (1, 2),
        (1, 5),
      ];

      final result = AStar.simplifyDirection(path, TypeResumeDirection.axisX);
      expect(result, equals(expected));
    });

    test('should simplify a path in the Y direction', () {
      final path = [
        (2, 1),
        (3, 1),
        (4, 1),
        (5, 1),
      ];
      final expected = [
        (2, 1),
        (5, 1),
      ];

      final result = AStar.simplifyDirection(path, TypeResumeDirection.axisY);
      expect(result, equals(expected));
    });

    test('should return an empty list for an empty path', () {
      final path = <(int, int)>[];
      final expected = <(int, int)>[];

      final result = AStar.simplifyDirection(path, TypeResumeDirection.axisX);
      expect(result, equals(expected));
    });
  });
}
