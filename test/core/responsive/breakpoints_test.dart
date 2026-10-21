import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/responsive/breakpoints.dart';
import 'package:kgwebo/core/responsive/window_size_class.dart';

void main() {
  test('classifies width into compact, medium and expanded', () {
    expect(KgweboBreakpoints.ofWidth(320), WindowSizeClass.compact);
    expect(KgweboBreakpoints.ofWidth(360), WindowSizeClass.compact);
    expect(KgweboBreakpoints.ofWidth(599), WindowSizeClass.compact);
    expect(KgweboBreakpoints.ofWidth(600), WindowSizeClass.medium);
    expect(KgweboBreakpoints.ofWidth(800), WindowSizeClass.medium);
    expect(KgweboBreakpoints.ofWidth(768), WindowSizeClass.medium);
    expect(KgweboBreakpoints.ofWidth(1023), WindowSizeClass.medium);
    expect(KgweboBreakpoints.ofWidth(1024), WindowSizeClass.expanded);
  });

  test('metric columns reflow with width', () {
    expect(KgweboBreakpoints.metricColumns(320), 1);
    expect(KgweboBreakpoints.metricColumns(360), 1);
    expect(KgweboBreakpoints.metricColumns(520), 2);
    expect(KgweboBreakpoints.metricColumns(900), 4);
  });
}
