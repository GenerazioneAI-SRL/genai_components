import 'dart:async';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_ghost_button.widget.dart';
import 'package:genai_components/widgets/cl_announcement/cl_announcemet.model.dart';
import 'package:genai_components/widgets/cl_text_field.widget.dart';
import 'package:genai_components/widgets/loading.widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cl_media_viewer.widget.dart';
import '../cl_pill.widget.dart';
import '../cl_responsive_grid/flutter_responsive_flex_grid.dart';
import '../excerpt_text.widget.dart';

import '../../utils/models/pagination.model.dart';
part 'cl_announcement_state.provider.dart';

class ClAnnouncementWidget<T extends Object> extends StatelessWidget {
  final Future Function(String)? onAnnouncementTap;
  final Future Function(String)? onAnnouncementRead;
  final int visibileExcerptAmount;
  final CLAnnouncement Function(T) onAnnouncementBuild;
  final String? searchColumn;
  final Future<void> Function(CLAnnouncement)? onMoreTap;
  final Future<dynamic> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) fetchAnnouncement;

  const ClAnnouncementWidget(
      {super.key,
      this.onAnnouncementTap,
      this.onAnnouncementRead,
      this.visibileExcerptAmount = 350,
      required this.fetchAnnouncement,
      required this.onAnnouncementBuild,
      this.onMoreTap,
      this.searchColumn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => _CLAnnouncementState(fetchAnnouncement: fetchAnnouncement, onAnnouncementBuild: onAnnouncementBuild),
        builder: (context, child) {
          var state = context.watch<_CLAnnouncementState<T>>();
          List<int> pageNumbers = _calculateVisiblePages(context, state.currentPage, state.lastPage);
          return ResponsiveGrid(
            children: [
              ResponsiveGridItem(
                lg: 50,
                xs: 100,
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.padding),
                  child: CLTextField(
                    controller: TextEditingController(),
                    labelText: "Cerca per titolo",
                    onChanged: (text) async {
                      state.onSearch({searchColumn!: text});
                    },
                  ),
                ),
              ),
              ResponsiveGridItem(
                  lg: 50,
                  xs: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: state.hasPreviousPage && state._announcementState != _AnnouncementState.loading
                                ? CLTheme.of(context).secondaryText
                                : CLTheme.of(context).alternate,
                          ),
                          onPressed: (state.hasPreviousPage && state._announcementState != _AnnouncementState.loading) ? state.previousPage : null,
                        ),
                        ...pageNumbers.map((page) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CircleAvatar(
                                backgroundColor: state.currentPage == page ? CLTheme.of(context).primary : Colors.transparent,
                                radius: 20,
                                child: TextButton(
                                  onPressed: () {
                                    if (state._announcementState != _AnnouncementState.loading) {
                                      state.goToPage(page);
                                    }
                                  },
                                  child: AutoSizeText(
                                    '$page',
                                    minFontSize: 5,
                                    style: CLTheme.of(context)
                                        .smallText
                                        .merge(TextStyle(color: state.currentPage == page ? Colors.white : CLTheme.of(context).primaryText)),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            )),
                        IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: state.hasNextPage && state._announcementState != _AnnouncementState.loading
                                ? CLTheme.of(context).secondaryText
                                : CLTheme.of(context).alternate,
                          ),
                          onPressed: (state.hasNextPage && state._announcementState != _AnnouncementState.loading) ? state.nextPage : null,
                        ),
                      ],
                    ),
                  )),
              ResponsiveGridItem(
                  lg: 100,
                  xs: 100,
                  child: state._announcementState == _AnnouncementState.ready
                      ? SingleChildScrollView(
                          child: ListView.separated(
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: CLTheme.of(context).borderColor,
                                  thickness: 1,
                                );
                              },
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: state.announcementList.length,
                              itemBuilder: (context, index) {
                                Color statusColor;
                                String statusText;
                                IconData statusIcon;
                                switch (state.announcementList[index].announcementPriority) {
                                  case CLAnnouncementPriority.normal:
                                    statusColor = CLTheme.of(context).info;
                                    statusText = "Normale";
                                    statusIcon = Icons.info;
                                    break;
                                  case CLAnnouncementPriority.warning:
                                    statusColor = CLTheme.of(context).warning;
                                    statusText = "Attenzione";
                                    statusIcon = Icons.warning;
                                    break;
                                  case CLAnnouncementPriority.urgent:
                                    statusColor = CLTheme.of(context).danger;
                                    statusText = "Urgente";
                                    statusIcon = Icons.priority_high_rounded;
                                    break;
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                        onTap: () async {
                                          if (onAnnouncementTap != null) {
                                            await onAnnouncementTap!(state.announcementList[index].id);
                                          }
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: Sizes.padding,
                                            right: Sizes.padding,
                                            bottom: state.announcementList[index].mediaUrls.isEmpty ? Sizes.padding - 6 : 0,
                                            top: index > 0 ? Sizes.padding - 6 : 0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ResponsiveGrid(
                                                children: [
                                                  ResponsiveGridItem(
                                                    lg: 50,
                                                    xs: 50,
                                                    child: CLPill(pillColor: statusColor, pillText: statusText, icon: statusIcon),
                                                  ),
                                                  ResponsiveGridItem(
                                                    lg: 50,
                                                    xs: 50,
                                                    child: onAnnouncementRead != null
                                                        ? state.announcementList[index].readedAt == null
                                                            ? CLGhostButton.primary(
                                                                text: "Segna come letto",
                                                                onTap: () async {
                                                                  await state.markAsRead(index, onAnnouncementRead);
                                                                },
                                                                context: context)
                                                            : Text(
                                                                "Letto il ${state.announcementList[index].formattedReadedAt}",
                                                                style: CLTheme.of(context).smallLabel,
                                                              )
                                                        : SizedBox.shrink(),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                state.announcementList[index].title.capitalize,
                                                style: CLTheme.of(context).subTitle.copyWith(fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.visible,
                                                maxLines: null,
                                              ),
                                              Text(
                                                "Creato il ${state.announcementList[index].formattedCreatedAt}",
                                                style: CLTheme.of(context).smallLabel,
                                                overflow: TextOverflow.visible,
                                                maxLines: null,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ExcerptText<CLAnnouncement>(
                                                  text: state.announcementList[index].subtitle,
                                                  textStyle: CLTheme.of(context).bodyText,
                                                  maxLength: visibileExcerptAmount,
                                                  onMoreTap: onMoreTap),
                                            ],
                                          ),
                                        )),
                                    SizedBox(height: 4),
                                    if (state.announcementList[index].mediaUrls.isNotEmpty) ...[
                                      Theme(
                                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                          child: ExpansionTile(
                                            minTileHeight: 0,
                                            showTrailingIcon: false,
                                            trailing: Icon(
                                              Icons.attach_file,
                                              color: CLTheme.of(context).primary,
                                            ),
                                            tilePadding: EdgeInsets.symmetric(horizontal: Sizes.padding),
                                            childrenPadding: EdgeInsets.zero,
                                            title: Row(
                                              children: [
                                                Text(
                                                  'Allegati',
                                                  style: CLTheme.of(context).bodyLabel.copyWith(color: CLTheme.of(context).primary),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.keyboard_arrow_down_rounded,
                                                  color: CLTheme.of(context).primary,
                                                  size: Sizes.medium,
                                                ),
                                              ],
                                            ),
                                            children: [
                                              CLMediaViewer(
                                                medias: state.announcementList[index].mediaUrls.map((mediaUrl) => CLMedia(fileUrl: mediaUrl)).toList(),
                                                isItemRemovable: false,
                                                clMediaViewerMode: CLMediaViewerMode.cardMode,
                                              ),
                                            ],
                                          )),
                                      SizedBox(height: 4),
                                    ]
                                  ],
                                );
                              }),
                        )
                      : LoadingWidget()),
            ],
          );
        });
  }

  List<int> _calculateVisiblePages(BuildContext context, int currentPage, int lastPage) {
    int group = (currentPage) ~/ 5;
    int start = group * 5 + 1;
    int end = (start + 4 <= lastPage) ? start + 4 : lastPage;
    return List.generate(end - start + 1, (index) => start + index);
  }
}
