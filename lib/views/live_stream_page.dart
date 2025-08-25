import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LiveStreamPage extends StatefulWidget {
  final ValueChanged<bool>? onFullScreenChanged;
  const LiveStreamPage({super.key, this.onFullScreenChanged});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  final String videoId = "5f__Ls4_VYQ"; // Cambialo por tu stream

  late YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();
    // Permitir todas las orientaciones al entrar a la pantalla
    controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: true,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_fullScreenListener);
  }

  void _fullScreenListener() {
    final isFullScreen = controller.value.isFullScreen;
    widget.onFullScreenChanged?.call(isFullScreen);
  }

  @override
  void dispose() {
    // Restaurar orientaciones permitidas al salir de la pantalla
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
    controller.removeListener(_fullScreenListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isFullScreen = controller.value.isFullScreen;

    if (isFullScreen) {
      // Solo muestra el reproductor ocupando toda la pantalla
      return Scaffold(
        body: SizedBox.expand(
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(controller: controller),
            builder: (context, player) {
              return Column(
                children: [
                  // some widgets
                  player,
                  //some other widgets
                ],
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: isLandscape
          ? null
          : AppBar(title: const Text("Ferro Web en Vivo"), centerTitle: true),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(controller: controller),
              builder: (context, player) {
                return Column(
                  children: [
                    // some widgets
                    player,
                    //some other widgets
                  ],
                );
              },
            ),
          ),
          // El resto del contenido se adapta al espacio disponible
          Expanded(
            child: Column(
              children: isLandscape
                  ? []
                  : [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "¡Disfrutá mi transmisión en vivo!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView(
                          children: const [
                            ListTile(
                              leading: Icon(Icons.play_circle),
                              title: Text("Otro video 1"),
                              subtitle: Text("Descripción breve"),
                            ),
                            ListTile(
                              leading: Icon(Icons.play_circle),
                              title: Text("Otro video 2"),
                              subtitle: Text("Descripción breve"),
                            ),
                          ],
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
