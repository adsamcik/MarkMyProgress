import 'package:myprogress/data/bookmark/abstract/progress.dart';
import 'package:myprogress/extensions/date.dart';
import 'package:rational/rational.dart';

class NoProgress implements Progress {
  @override
  DateTime get date => Date.invalid;

  @override
  Rational get value => Rational.zero;
}
