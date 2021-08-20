import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:share/share.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionAlbumTab extends StatelessWidget {
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    double tileWidth =
        (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) /
            elementsPerRow;
    double tileHeight = tileWidth * 260.0 / 156;

    return Consumer<Collection>(
      builder: (context, collection, _) => collection.tracks.isNotEmpty
          ? ListView(
              children: tileGridListWidgets(
                context: context,
                tileHeight: tileHeight,
                tileWidth: tileWidth,
                elementsPerRow: elementsPerRow,
                subHeader: language!.STRING_LOCAL_OTHER_SUBHEADER_ALBUM,
                leadingSubHeader: language!.STRING_LOCAL_TOP_SUBHEADER_ALBUM,
                widgetCount: collection.albums.length,
                leadingWidget: LeadingCollectionAlbumTile(
                  height: tileWidth,
                ),
                builder: (BuildContext context, int index) =>
                    CollectionAlbumTile(
                  height: tileHeight,
                  width: tileWidth,
                  album: collection.albums[index],
                ),
              ),
            )
          : Center(
              child: ExceptionWidget(
                height: 256.0,
                width: 420.0,
                margin: EdgeInsets.zero,
                title: language!.STRING_NO_COLLECTION_TITLE,
                subtitle: language!.STRING_NO_COLLECTION_SUBTITLE,
              ),
            ),
    );
  }
}

class CollectionAlbumTile extends StatelessWidget {
  final double? height;
  final double? width;
  final Album album;

  const CollectionAlbumTile({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: InkWell(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: CollectionAlbum(
                  album: this.album,
                ),
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'album_art_${this.album.albumName}',
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                child: Image.file(
                  this.album.albumArt,
                  fit: BoxFit.fill,
                  height: this.width,
                  width: this.width,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              height: this.height! - this.width!,
              width: this.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      this.album.albumName!,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '${this.album.albumArtistName}\n(${this.album.year ?? 'Unknown Year'})',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black.withOpacity(0.8),
                        fontSize: 14.0,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeadingCollectionAlbumTile extends StatelessWidget {
  final double height;

  const LeadingCollectionAlbumTile({Key? key, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 4.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: CollectionAlbum(
                  album: Provider.of<Collection>(context, listen: false)
                      .lastAlbum!,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        child: Container(
          height: this.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).cardColor,
          ),
          width: MediaQuery.of(context).size.width - 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                  tag:
                      'album_art_${Provider.of<Collection>(context, listen: false).lastAlbum!.albumName!}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image(
                      image: FileImage(
                          Provider.of<Collection>(context, listen: false)
                              .lastAlbum!
                              .albumArt),
                      fit: BoxFit.fill,
                      height: this.height,
                      width: this.height,
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                width: MediaQuery.of(context).size.width - 32 - this.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Provider.of<Collection>(context, listen: false)
                          .lastAlbum!
                          .albumName!,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    Text(
                      Provider.of<Collection>(context, listen: false)
                          .lastAlbum!
                          .albumArtistName!,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black.withOpacity(0.8),
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                    Text(
                      '(${Provider.of<Collection>(context, listen: false).lastAlbum!.year ?? 'Unknown Year'})',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black.withOpacity(0.8),
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionAlbum extends StatelessWidget {
  final Album? album;
  const CollectionAlbum({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                NavigatorPopButton(),
                SizedBox(
                  width: 24.0,
                ),
                Text(
                  'Album',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                )
              ],
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: Hero(
                      tag: 'album_art_${this.album!.albumName}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.file(
                          this.album!.albumArt,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          width: 256.0,
                          height: 256.0,
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.0),
                  Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          this.album!.albumName!,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          '${this.album!.albumArtistName}\n(${this.album!.year ?? 'Unknown Year'})',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.black.withOpacity(0.8),
                            fontSize: 14.0,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Play Now',
                        ),
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Add to Now Playing',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      builder: (context, collection, child) => Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              child!,
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                        Container(
                          height: 56.0,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 24.0),
                          child: Text(
                            'Tracks from this album.',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ] +
                      this
                          .album!
                          .tracks
                          .map(
                            (Track track) => Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: new Material(
                                color: Colors.transparent,
                                child: new ListTile(
                                  onTap: () async {
                                    await Playback.play(
                                      index: this.album!.tracks.indexOf(track),
                                      tracks: this.album!.tracks,
                                    );
                                  },
                                  title: Text(
                                    track.trackName!,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    track.trackArtistNames!.join(', '),
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.black.withOpacity(0.8),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    child: Text('${track.trackNumber ?? 1}'),
                                    backgroundImage:
                                        FileImage(this.album!.albumArt),
                                  ),
                                  trailing: PopupMenuButton(
                                    color: Theme.of(context).appBarTheme.color,
                                    elevation: 0,
                                    onSelected: (dynamic index) {
                                      switch (index) {
                                        case 0:
                                          {
                                            showDialog(
                                              context: context,
                                              builder: (subContext) =>
                                                  AlertDialog(
                                                title: Text(
                                                  language!
                                                      .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                                  style: Theme.of(subContext)
                                                      .textTheme
                                                      .headline1,
                                                ),
                                                content: Text(
                                                  language!
                                                      .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                                  style: Theme.of(subContext)
                                                      .textTheme
                                                      .headline5,
                                                ),
                                                actions: [
                                                  MaterialButton(
                                                    textColor: Theme.of(context)
                                                        .primaryColor,
                                                    onPressed: () async {
                                                      Navigator.of(subContext)
                                                          .pop();
                                                      await collection
                                                          .delete(track);
                                                      if (album!
                                                          .tracks.isEmpty) {
                                                        while (Navigator.of(
                                                                context)
                                                            .canPop())
                                                          Navigator.of(context)
                                                              .pop();
                                                      }
                                                    },
                                                    child: Text(
                                                        language!.STRING_YES),
                                                  ),
                                                  MaterialButton(
                                                    textColor: Theme.of(context)
                                                        .primaryColor,
                                                    onPressed:
                                                        Navigator.of(subContext)
                                                            .pop,
                                                    child: Text(
                                                        language!.STRING_NO),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          break;
                                        case 1:
                                          {
                                            Share.shareFiles(
                                              [track.filePath!],
                                              subject:
                                                  '${track.trackName} - ${track.albumName}.',
                                            );
                                          }
                                          break;
                                        case 2:
                                          {
                                            showDialog(
                                              context: context,
                                              builder: (subContext) =>
                                                  AlertDialog(
                                                contentPadding: EdgeInsets.zero,
                                                actionsPadding: EdgeInsets.zero,
                                                title: Text(
                                                  language!
                                                      .STRING_PLAYLIST_ADD_DIALOG_TITLE,
                                                  style: Theme.of(subContext)
                                                      .textTheme
                                                      .headline1,
                                                ),
                                                content: Container(
                                                  height: 280,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 24,
                                                                top: 8,
                                                                bottom: 16),
                                                        child: Text(
                                                          language!
                                                              .STRING_PLAYLIST_ADD_DIALOG_BODY,
                                                          style: Theme.of(
                                                                  subContext)
                                                              .textTheme
                                                              .headline5,
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 236,
                                                        width: 280,
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border(
                                                          top: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor,
                                                              width: 1),
                                                          bottom: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor,
                                                              width: 1),
                                                        )),
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: collection
                                                              .playlists.length,
                                                          itemBuilder: (BuildContext
                                                                      context,
                                                                  int playlistIndex) =>
                                                              ListTile(
                                                            title: Text(
                                                                collection
                                                                    .playlists[
                                                                        playlistIndex]
                                                                    .playlistName!,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline2),
                                                            leading: Icon(
                                                              Icons.queue_music,
                                                              size: Theme.of(
                                                                      context)
                                                                  .iconTheme
                                                                  .size,
                                                              color: Theme.of(
                                                                      context)
                                                                  .iconTheme
                                                                  .color,
                                                            ),
                                                            onTap: () async {
                                                              await collection
                                                                  .playlistAddTrack(
                                                                collection
                                                                        .playlists[
                                                                    playlistIndex],
                                                                track,
                                                              );
                                                              Navigator.of(
                                                                      subContext)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  MaterialButton(
                                                    textColor: Theme.of(context)
                                                        .primaryColor,
                                                    onPressed:
                                                        Navigator.of(subContext)
                                                            .pop,
                                                    child: Text(language!
                                                        .STRING_CANCEL),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          break;
                                      }
                                    },
                                    icon: Icon(Icons.more_vert,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                        size: Theme.of(context).iconTheme.size),
                                    tooltip: language!.STRING_OPTIONS,
                                    itemBuilder: (_) => <PopupMenuEntry>[
                                      PopupMenuItem(
                                        value: 0,
                                        child: Text(
                                          language!.STRING_DELETE,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text(
                                          language!.STRING_SHARE,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 2,
                                        child: Text(
                                          language!.STRING_ADD_TO_PLAYLIST,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
