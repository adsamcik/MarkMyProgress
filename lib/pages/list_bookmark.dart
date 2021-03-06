import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myprogress/data/bookmark/abstract/persistent_bookmark.dart';
import 'package:myprogress/data/bookmark/abstract/web_bookmark.dart';
import 'package:myprogress/data/bookmark/bloc/bloc.dart';
import 'package:myprogress/data/bookmark/bloc/bookmark_bloc_event.dart';
import 'package:myprogress/data/bookmark/instance/generic_bookmark.dart';
import 'package:myprogress/extensions/bookmark.dart';
import 'package:myprogress/extensions/context.dart';
import 'package:myprogress/extensions/date.dart';
import 'package:myprogress/extensions/number.dart';
import 'package:myprogress/generated/locale_keys.g.dart';
import 'package:myprogress/misc/app_icons.dart';
import 'package:myprogress/misc/get.dart';
import 'package:myprogress/misc/platform.dart';
import 'package:myprogress/pages/settings.dart';
import 'package:myprogress/pages/statistics.dart';
import 'package:myprogress/pages/view_bookmark.dart';
import 'package:myprogress/widgets/progress_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_bookmark.dart';

class BookmarkList extends StatefulWidget {
  BookmarkList({Key key}) : super(key: key);

  @override
  _BookmarkListState createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {
  void _addNewItem() async {
    var newItem = GenericBookmark();
    await context.navigate<void>((context) => EditBookmark(bookmark: newItem));
  }

  void _viewDetail(PersistentBookmark bookmark) async {
    await context.navigate<void>((context) => ViewBookmark(bookmarkKey: bookmark.key));
  }

  final TextEditingController _searchQueryController = TextEditingController();

  void _showProgressSheet(PersistentBookmark bookmark) async {
    var result = await showProgressBottomSheet(context, bookmark);
    if (result != null) {
      bookmark.logProgress(result);
      GetIt.instance.get<BookmarkBloc>().add(BookmarkBlocEvent.saveBookmark(bookmark: bookmark));
    }
  }

  Widget _buildBookmarkButtons(PersistentBookmark bookmark) {
    const buttonSpacing = 16;
    const approxFirstButtonSize = 76;
    const approxButtonSize = approxFirstButtonSize + buttonSpacing;
    const requiredSpace = 7 * 38;
    var width = MediaQuery.of(context).size.width;
    var leftButtonSpace = width - requiredSpace;

    if (leftButtonSpace < approxFirstButtonSize) return SizedBox();

    var buttons = <Widget>[];

    buttons.add(OutlineButton(
        child: Text('+ ${bookmark.progressIncrement.toDecimalString()}'),
        onPressed: () => context.bloc<BookmarkBloc>().add(BookmarkBlocEvent.incrementProgress(bookmark: bookmark))));

    leftButtonSpace -= approxFirstButtonSize;

    if (leftButtonSpace >= approxButtonSize &&
        bookmark is WebBookmark &&
        ((bookmark as WebBookmark).webAddress ?? '').isNotEmpty) {
      buttons.add(SizedBox(width: 16));
      buttons.add(OutlineButton(
          child: Text(LocaleKeys.web).tr(),
          onPressed: () {
            // can launch is not implemented on Windows
            //canLaunch(webBookmark.webAddress).then((value) {
            //if (value) {
            launch((bookmark as WebBookmark).webAddress);
            //}
            //});
          }));
      leftButtonSpace -= approxButtonSize;
    }

    return Row(children: buttons.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          BlocBuilder<BookmarkBloc, BookmarkBlocState>(
            builder: (context, state) {
              return state.maybeWhen(
                ready: (version, bookmarkList, filteredBookmarkList, searchList, filterData) {
                  return Scrollbar(
                      controller: ScrollController(initialScrollOffset: 0),
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(0, 72, 0, 96),
                        separatorBuilder: (context, index) => Divider(
                          color: Get.theme(context).dividerColor,
                          height: 0,
                        ),
                        itemCount: searchList.length,
                        itemBuilder: (context, index) {
                          var item = searchList[index];
                          var bookmark = item.value;

                          String title;
                          if (kDebugMode && item.match != 1) {
                            title = '${bookmark.title} - (${item.match.toPrecision(2).toString()})';
                          } else {
                            title = bookmark.title;
                          }

                          var lastProgressDate = bookmark.lastProgress.date == Date.invalid
                              ? ''
                              : bookmark.lastProgress.date.toDateString();

                          const minOpacity = 0.5;
                          var opacityDouble =
                              ((item.match - BookmarkBloc.filterThreshold) / (1 - BookmarkBloc.filterThreshold));
                          var opacity = minOpacity + opacityDouble * (1 - minOpacity);

                          return InkWell(
                              onTap: () => _showProgressSheet(bookmark),
                              onLongPress: () => _viewDetail(bookmark),
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Row(children: [
                                      ConstrainedBox(
                                          constraints: BoxConstraints.tightForFinite(width: 90),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${bookmark.progress.toDecimalString()} / ${bookmark.maxProgress.toDecimalString()}',
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
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    title,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  )))),
                                      SizedBox(width: 16),
                                      _buildBookmarkButtons(bookmark),
                                    ]),
                                  )));
                        },
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
                color: Get.theme(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                elevation: 2,
                child: PreferredSize(
                    preferredSize: Size.fromHeight(64),
                    child: Row(children: [
                      Expanded(
                          child: TextField(
                        controller: _searchQueryController,
                        autofocus: AppPlatform.isDesktop,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          hintText: LocaleKeys.search.tr(),
                          border: InputBorder.none,
                        ),
                        onChanged: (query) =>
                            context.bloc<BookmarkBloc>().add(BookmarkBlocEvent.updateFilterQuery(query: query)),
                      )),
                      IconButton(
                          onPressed: () {
                            context.navigate<dynamic>((context) => Statistics());
                          },
                          icon: Icon(AppIcons.insert_chart)),
                      IconButton(
                          onPressed: () async {
                            await context.navigate<dynamic>((context) => Settings());
                          },
                          icon: Icon(AppIcons.settings_applications)),
                      SizedBox(
                        width: 8,
                      )
                    ]))),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewItem(),
        tooltip: LocaleKeys.add_bookmark.tr(),
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
