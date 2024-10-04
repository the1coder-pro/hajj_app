import 'package:flutter/material.dart';

class Path {
  const Path(this.pattern, this.builder);

  final String pattern;
  final Widget Function(BuildContext, Map<String, String>) builder;
}

// static List<Path> paths = [
//   Path(
//     r'^/'
//   ),
// ];
