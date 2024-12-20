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

  group('AStar', () {
    test('initialization with valid parameters', () {
      final aStar = AStar(
        rows: 5,
        columns: 5,
        start: (0, 0),
        end: (4, 4),
        barriers: [],
      );

      expect(aStar.grid.length, equals(5));
      expect(aStar.grid[0].length, equals(5));
    });

    group('findThePath', () {
      test('finds direct path without barriers', () {
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (0, 0),
          end: (2, 2),
          barriers: [],
        );

        final path = aStar.findThePath().toList();
        expect(path, contains((0, 0)));
        expect(path, contains((2, 2)));
      });

      test('finds path with barriers', () {
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (0, 0),
          end: (2, 2),
          barriers: [(1, 1)],
        );

        final path = aStar.findThePath().toList();
        expect(path.contains((1, 1)), isFalse);
      });

      test('returns empty path when end is unreachable', () {
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (0, 0),
          end: (2, 2),
          barriers: [
            (1, 1),
            (1, 2),
            (2, 1),
          ],
        );

        final path = aStar.findThePath().toList();
        expect(path, isEmpty);
      });

      test('handles path without diagonal movement', () {
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (0, 0),
          end: (2, 2),
          barriers: [],
          withDiagonal: false,
        );

        final path = aStar.findThePath().toList();
        expect(path.length, greaterThan(2)); // Should take more steps
      });
    });

    group('edge cases', () {
      test('start point equals end point', () {
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (1, 1),
          end: (1, 1),
          barriers: [],
        );

        final path = aStar.findThePath().toList();
        expect(path.length, equals(2));
        expect(path.first, equals((1, 1)));
      });

      test('end point is barrier', () {
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (0, 0),
          end: (2, 2),
          barriers: [(2, 2)],
        );

        final path = aStar.findThePath().toList();
        expect(path, isEmpty);
      });

      test('path along grid boundaries', () {
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (0, 0),
          end: (2, 0),
          barriers: [],
        );

        final path = aStar.findThePath().toList();
        expect(path.first, equals((0, 0)));
        expect(path.last, equals((2, 0)));
      });
    });

    group('callback testing', () {
      test('doneList callback provides visited tiles', () {
        List<(int, int)>? visitedTiles;
        final aStar = AStar(
          rows: 3,
          columns: 3,
          start: (0, 0),
          end: (2, 2),
          barriers: [],
        );

        aStar.findThePath(
          doneList: (tiles) {
            visitedTiles = tiles;
          },
        ).toList();

        expect(visitedTiles, isNotNull);
        expect(visitedTiles, isNotEmpty);
      });
    });
  });
}
