import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_drawer.dart';

/// Shared scaffold that provides a consistent AppBar with the hamburger menu
/// icon on the top-right (opening an endDrawer) across every screen.
class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final String currentRoute;
  final bool showBackButton;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final List<Widget>? extraActions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRoute,
    this.showBackButton = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extraActions,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF000000),
      drawerScrimColor: Colors.black.withOpacity(0.5),
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(currentRoute: widget.currentRoute),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: (widget.showBackButton && canPop)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.shield, color: Color(0xFFE5E5E5)),
                ),
              ),
        title: Text(
          widget.title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (widget.extraActions != null) ...widget.extraActions!,
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Menu',
          ),
          const SizedBox(width: 4),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.body,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
