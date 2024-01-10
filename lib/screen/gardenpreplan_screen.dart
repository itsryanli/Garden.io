import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class GardenPreplanScreen extends StatefulWidget {
  const GardenPreplanScreen({Key? key}) : super(key: key);

  @override
  State<GardenPreplanScreen> createState() => _GardenPreplanScreenState();
}

class _GardenPreplanScreenState extends State<GardenPreplanScreen> {
  late TextEditingController textController;
  late FocusNode focusNode;
  late YoutubePlayerController _controller;
  String plantationName = 'strawberry';

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    _controller = YoutubePlayerController(
      initialVideoId: 'C-BNMejE8ro',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  String getVideoId(String plantationName) {
    switch (plantationName.toLowerCase()) {
      case 'strawberry':
        return 'C-BNMejE8ro';
      case 'tomato':
        return 'oHjsbh4nfXk';
      case 'potato':
        return 'oaE6T-5b_ZU';
      case 'corn':
        return '4augXLWqeXw';
      default:
        return 'C-BNMejE8ro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      appBar: AppBar(
        title: const Text('Garden Preplan'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // title
                const Text(
                  'Find the planting tutorial!',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        autofocus: true,
                        autocorrect: true,
                        focusNode: focusNode,
                        controller: textController,
                        onFieldSubmitted: (value) {
                          textController.clear();
                          setState(() {
                            _controller.load(getVideoId(value));
                            focusNode.requestFocus();
                            plantationName = value.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5.5),
                              bottomLeft: Radius.circular(5.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          labelText: "Enter the plantation name",
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: 450,
                    width: 300,
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String videoId = getVideoId(plantationName);
                        String youtubeLink =
                            'https://www.youtube.com/watch?v=$videoId';
                        await launchUrl(Uri.parse(youtubeLink));
                      },
                      child: const Text('View in Youtube'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> launchUrl(Uri uri) async {
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch';
    }
  }
}
