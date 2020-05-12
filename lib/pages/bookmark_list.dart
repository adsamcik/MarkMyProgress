import 'package:MarkMyProgress/data/bookmark/abstract/IPersistentBookmark.dart';
import 'package:MarkMyProgress/data/bookmark/abstract/IWebBookmark.dart';
import 'package:MarkMyProgress/data/bookmark/bloc/bloc.dart';
import 'package:MarkMyProgress/data/bookmark/instance/GenericBookmark.dart';
import 'package:MarkMyProgress/extensions/DateExtension.dart';
import 'package:MarkMyProgress/extensions/UserBookmark.dart';
import 'package:MarkMyProgress/pages/settings.dart';
import 'package:MarkMyProgress/pages/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_record.dart';

class BookmarkList extends StatefulWidget {
  BookmarkList({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _BookmarkListState createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {
  Future<T> navigate<T>(WidgetBuilder builder) async {
    return await Navigator.push<T>(
      context,
      MaterialPageRoute<T>(builder: builder),
    );
  }

  void _addNewItem(BuildContext context) async {
    var newItem = GenericBookmark();
    var bookmark = await navigate<IPersistentBookmark>(
        (context) => EditRecord(bookmark: newItem));

    if (bookmark == null) {
      return;
    }

    // todo move this inside edit
    context
        .bloc<BookmarkBloc>()
        .add(BookmarkBlocEvent.addBookmark(bookmark: bookmark));
  }

  void _viewDetail(IPersistentBookmark bookmark) async {
    var item = await navigate<IPersistentBookmark>(
        (context) => EditRecord(bookmark: bookmark));

    if (item == null) {
      return;
    }

    // todo move this inside edit
    context
        .bloc<BookmarkBloc>()
        .add(BookmarkBlocEvent.updateBookmark(bookmark: bookmark));
  }

  final TextEditingController _searchQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          BlocBuilder<BookmarkBloc, BookmarkBlocState>(
            builder: (context, state) {
              return state.maybeWhen(
                ready:
                    (version, bookmarkList, filteredBookmarkList, filterData) {
                  return Scrollbar(
                      controller: ScrollController(initialScrollOffset: 0),
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(0, 72, 0, 96),
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).dividerColor,
                          height: 0,
                        ),
                        itemBuilder: (context, index) {
                          var item = filteredBookmarkList[index];
                          var bookmark = item.value;

                          String title;
                          if (kDebugMode && item.match != 1) {
                            title =
                                '${bookmark.title} - (${item.match.toStringAsFixed(2)})';
                          } else {
                            title = bookmark.title;
                          }

                          var lastProgressDate =
                              bookmark.lastProgress.date == Date.invalid
                                  ? ''
                                  : bookmark.lastProgress.date.toDateString();
                          return InkWell(
                              onTap: () => _viewDetail(bookmark),
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: Opacity(
                                    opacity: item.match,
                                    child: Row(children: [
                                      ConstrainedBox(
                                          constraints:
                                              BoxConstraints.tightForFinite(
                                                  width: 90),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${bookmark.progress} / ${bookmark.maxProgress}',
                                                maxLines: 1,
                                              ),
                                              Text(
                                                lastProgressDate,
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                              ),
                                            ],
                                          )),
                                      SizedBox(width: 16),
                                      Expanded(
                                          child: Container(
                                              height: 40,
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )))),
                                      SizedBox(width: 16),
                                      if (bookmark is IWebBookmark &&
                                          ((bookmark as IWebBookmark)
                                                      .webAddress ??
                                                  '')
                                              .isNotEmpty)
                                        OutlineButton(
                                            child: Text('Web'),
                                            onPressed: () {
                                              // can launch is not implemented on Windows
                                              //canLaunch(webBookmark.webAddress).then((value) {
                                              //if (value) {
                                              launch((bookmark as IWebBookmark)
                                                  .webAddress);
                                              //}
                                              //});
                                            }),
                                      OutlineButton(
                                          child: Text(
                                              '+ ${bookmark.progressIncrement}'),
                                          onPressed: () => context
                                              .bloc<BookmarkBloc>()
                                              .add(BookmarkBlocEvent
                                                  .incrementProgress(
                                                      bookmark: bookmark))),
                                    ]),
                                  )));
                        },
                        itemCount: filteredBookmarkList.length,
                      ));
                },
                orElse: () => Container(),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                elevation: 2,
                child: PreferredSize(
                    preferredSize: Size.fromHeight(64),
                    child: Row(children: [
                      Expanded(
                          child: TextField(
                        controller: _searchQueryController,
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                        onChanged: (query) => context.bloc<BookmarkBloc>().add(
                            BookmarkBlocEvent.updateFilterQuery(query: query)),
                      )),
                      IconButton(
                          onPressed: () {
                            navigate<dynamic>((context) => Statistics());
                          },
                          icon: Icon(
                            Icons.insert_chart,
                          )),
                      IconButton(
                          onPressed: () async {
                            await navigate<dynamic>((context) => Settings());
                          },
                          icon: Icon(
                            Icons.settings,
                          )),
                    ]))),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewItem(context),
        tooltip: 'Add new bookmark',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}