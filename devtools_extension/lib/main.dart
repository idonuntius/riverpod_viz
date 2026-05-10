import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

import 'src/ui/timeline_page.dart';

/// Entry point for the riverpod_viz DevTools extension web app.
void main() {
  runApp(const RiverpodVizDevToolsExtension());
}

/// Root widget that wraps the timeline UI in a [DevToolsExtension] shell.
class RiverpodVizDevToolsExtension extends StatelessWidget {
  /// Creates the extension root widget.
  const RiverpodVizDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(child: TimelinePage());
  }
}
