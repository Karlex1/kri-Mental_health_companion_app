import 'package:flutter/material.dart';
import 'video.dart'; // Import Video model

class VideoPage extends StatelessWidget {
  final List<Video> videos;

  VideoPage({required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(child: Text('No video recommendations available.'));
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Image.network(video.thumbnail, width: 80, fit: BoxFit.cover),
            title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(video.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            onTap: () {
              // Uncomment below to launch the video
              // final url = 'https://www.youtube.com/watch?v=${video.videoId}';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // } else {
              //   throw 'Could not launch $url';
              // }
            },
          ),
        );
      },
    );
  }
}
