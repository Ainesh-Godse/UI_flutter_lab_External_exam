import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Experiment 3: MediaQuery for responsiveness
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 800; // Tablet/Desktop breakpoint

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // Show settings icon only on mobile, since desktop has it on the rail
        actions: isDesktop ? null : [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => onDestinationSelected(3), // Settings index
          )
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Show NavigationRail on large screens
            if (isDesktop)
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.book_outlined),
                    selectedIcon: Icon(Icons.book),
                    label: Text('Subjects'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calculate_outlined),
                    selectedIcon: Icon(Icons.calculate),
                    label: Text('Calculator'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),

            // Divider between rail and body
            if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

            // Main Content
            Expanded(
              // Constrain content width on ultra-wide screens
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),

      // Show BottomNav on small screens
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calc'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}