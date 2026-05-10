import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

import 'src/ui/timeline_page.dart';

void main() {
  runApp(const RiverpodVizDevToolsExtension());
}

class RiverpodVizDevToolsExtension extends StatelessWidget {
  const RiverpodVizDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(child: TimelinePage());
  }
}
