/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/interface/collection/collectionartist.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionSearch extends StatefulWidget {
  final ValueNotifier<String>? query;
  CollectionSearch({Key? key, this.query}) : super(key: key);
  CollectionSearchState createState() => CollectionSearchState();
}

class CollectionSearchState extends State<CollectionSearch> {
  TextEditingController controller = new TextEditingController();
  bool get search =>
      _albums.length == 0 && _tracks.length == 0 && _artists.length == 0;
  bool get albums => _albums.length == 0;
  bool get tracks => _tracks.length == 0;
  bool get artists => _artists.length == 0;
  List<Widget> _albums = <Widget>[];
  List<Widget> _tracks = <Widget>[];
  List<Widget> _artists = <Widget>[];
  int index = 0;
  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      this.listener = () async {
        List<dynamic> resultCollection =
            await collection.search(widget.query!.value);
        List<Widget> albums = <Widget>[];
        List<Widget> tracks = <Widget>[];
        List<Widget> artists = <Widget>[];
        for (dynamic item in resultCollection) {
          if (item is Album) {
            albums.add(
              CollectionAlbumTile(
                height: 224.0,
                width: 172.0,
                album: item,
              ),
            );
          }
          if (item is Artist) {
            artists.add(
              CollectionArtistTile(
                height: 172.0 + 18.0,
                width: 172.0,
                artist: item,
              ),
            );
          } else if (item is Track) {
            tracks.add(
              CollectionTrackTile(
                track: item,
                index: collection.tracks.indexOf(item),
              ),
            );
          }
        }
        this._albums = albums;
        this._artists = artists;
        this._tracks = tracks;
        setState(() {});
      };
      widget.query!.addListener(this.listener);
      listener();
    }
  }

  @override
  void dispose() {
    widget.query!.removeListener(this.listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            if (widget.query == null)
              Container(
                margin: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: 8.0,
                      ),
                      child: Container(
                        width: 56.0,
                        child: Icon(
                          FluentIcons.search_24_regular,
                          size: 24.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            HotKeys.disableSpaceHotKey();
                          } else {
                            HotKeys.enableSpaceHotKey();
                          }
                        },
                        child: TextField(
                          autofocus: Platform.isWindows ||
                              Platform.isLinux ||
                              Platform.isMacOS,
                          controller: controller,
                          onChanged: (String query) async {
                            int localIndex = index;
                            index++;
                            List<dynamic> resultCollection =
                                await collection.search(query);
                            List<Widget> albums = <Widget>[];
                            List<Widget> tracks = <Widget>[];
                            List<Widget> artists = <Widget>[];
                            for (dynamic item in resultCollection) {
                              if (item is Album) {
                                albums.add(
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 8.0, bottom: 8.0, right: 8.0),
                                    child: CollectionAlbumTile(
                                      height: 224.0,
                                      width: 172.0,
                                      album: item,
                                    ),
                                  ),
                                );
                              }
                              if (item is Artist) {
                                artists.add(
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 8.0, bottom: 8.0, right: 8.0),
                                    child: CollectionArtistTile(
                                      height: 172.0 + 24.0,
                                      width: 172.0,
                                      artist: item,
                                    ),
                                  ),
                                );
                              } else if (item is Track) {
                                tracks.add(
                                  CollectionTrackTile(
                                    track: item,
                                    index: collection.tracks.indexOf(item),
                                  ),
                                );
                              }
                            }
                            if (localIndex == index - 1) {
                              this._albums = albums;
                              this._artists = artists;
                              this._tracks = tracks;
                              setState(() {});
                            }
                          },
                          style: Theme.of(context).textTheme.headline4,
                          cursorWidth: 1.0,
                          decoration: InputDecoration(
                            hintText: language.COLLECTION_SEARCH_LABEL,
                            hintStyle: Theme.of(context).textTheme.headline3,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24.0,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: search
                  ? (controller.text.isEmpty
                      ? Center(
                          child: Icon(
                            FluentIcons.search_20_regular,
                            size: 72.0,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FluentIcons.emoji_sad_24_regular,
                                  size: 72.0,
                                  color: Theme.of(context).iconTheme.color),
                              Divider(
                                color: Colors.transparent,
                                height: 12.0,
                              ),
                              Text(
                                language.COLLECTION_SEARCH_NO_RESULTS,
                                style: Theme.of(context).textTheme.headline3,
                              )
                            ],
                          ),
                        ))
                  : CustomListView(
                      children: <Widget>[
                            albums
                                ? Container()
                                : Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, bottom: 8.0),
                                    child: SubHeader(language.ALBUM),
                                  ),
                            albums
                                ? Container()
                                : Container(
                                    height: 224.0,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width
                                        .normalized,
                                    child: CustomListView(
                                      scrollDirection: Axis.horizontal,
                                      children: _albums,
                                    ),
                                  ),
                            artists
                                ? Container()
                                : Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, bottom: 8.0),
                                    child: SubHeader(language.ARTIST),
                                  ),
                            artists
                                ? Container()
                                : Container(
                                    height: 172.0 + 18.0,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width
                                        .normalized,
                                    child: CustomListView(
                                      scrollDirection: Axis.horizontal,
                                      children: _artists,
                                    ),
                                  ),
                            tracks
                                ? Container()
                                : Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, bottom: 8.0),
                                    child: SubHeader(language.TRACK),
                                  ),
                          ] +
                          (tracks
                              ? [
                                  Container(),
                                ]
                              : _tracks),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
