import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_viewer_app/views/home_view.dart';
import 'package:mi_viewer_app/views/live_stream_page.dart';

// Provider para el índice de la página actual
final pageIndexProvider = StateProvider<int>((ref) => 0);

class NavigationMain extends ConsumerWidget {
  const NavigationMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentPageIndex = ref.watch(pageIndexProvider);
    final ThemeData theme = Theme.of(context);
    bool isLiveStreamFullScreen = false; // Esto debería ser manejado por un provider también si se vuelve más complejo

    return Scaffold(
      bottomNavigationBar: isLiveStreamFullScreen
          ? null
          : NavigationBar(
              onDestinationSelected: (int index) {
                ref.read(pageIndexProvider.notifier).state = index;
              },
              indicatorColor: Colors.amber,
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Noticias',
                ),
                NavigationDestination(
                  icon: Badge(child: Icon(Icons.ondemand_video)),
                  label: 'En Vivo',
                ),
                NavigationDestination(
                  icon: Badge(child: Icon(Icons.calendar_month)),
                  label: 'Fechas',
                ),
              ],
            ),
      body: <Widget>[
        /// Home page
        HomeView(),

        /// Notifications page
        LiveStreamPage(
          onFullScreenChanged: (isFullScreen) {
            // Lógica para manejar el estado de pantalla completa
          },
        ),

        /// Messages page
        ListView.builder(
          reverse: true,
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Hello',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            }
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Hi!',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ][currentPageIndex],
    );
  }
}
