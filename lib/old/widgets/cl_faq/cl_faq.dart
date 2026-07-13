import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_container.widget.dart';
import 'models/cl_faq_category.model.dart';

class CLFaqWidget extends StatefulWidget {
  const CLFaqWidget({super.key, required this.faqCategories});

  final List<CLFaqCategory> faqCategories;

  @override
  State<CLFaqWidget> createState() => _CLFaqWidgetState();
}

class _CLFaqWidgetState extends State<CLFaqWidget> {
  CLFaqCategory? selectedFaqCategory;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CLContainer(
        contentMargin: const EdgeInsets.all(Sizes.padding),
        contentPadding: EdgeInsets.zero,
        child: selectedFaqCategory != null ? _buildCompo2() : _buildCompo1());
  }

  Widget _buildCompo1() {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Categorie FAQ",
            style: CLTheme.of(context).heading4,
          ),
          subtitle: Text("Seleziona una categoria per visualizzare le reletive FAQ", style: CLTheme.of(context).bodyLabel),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) {
              return Divider(
                indent: Sizes.padding,
                endIndent: Sizes.padding,
              );
            },
            shrinkWrap: true,
            itemCount: widget.faqCategories.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    setState(() {
                      selectedFaqCategory = widget.faqCategories[index];
                    });
                  },
                  child: ListTile(
                      trailing: Icon(
                        Icons.chevron_right,
                        color: CLTheme.of(context).primaryText,
                      ),
                      subtitle: Text(
                        widget.faqCategories[index].description,
                        style: CLTheme.of(context).bodyLabel,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: Sizes.gapSm),
                        child: Text(
                          widget.faqCategories[index].title,
                          style: CLTheme.of(context).title,
                        ),
                      )));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompo2() {
    return selectedFaqCategory != null
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ListTile(
                minTileHeight: 0,
                minVerticalPadding: 0,
                contentPadding: EdgeInsets.all(Sizes.padding),
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    {
                      setState(() {
                        selectedFaqCategory = null;
                      });
                    }
                  },
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: Sizes.iconSizeDefault, color: CLTheme.of(context).primary),
                ),
                title: Text(
                  selectedFaqCategory!.title,
                  style: CLTheme.of(context).heading4,
                )),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) {
                  return Divider(
                    indent: 0,
                    endIndent: 0,
                    thickness: 1,
                    color: CLTheme.of(context).borderColor,
                  );
                },
                itemCount: selectedFaqCategory!.faqs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        minTileHeight: 0,
                        tilePadding: EdgeInsets.only(left: Sizes.padding, right: Sizes.padding),
                        childrenPadding: EdgeInsets.only(left: Sizes.padding, right: Sizes.padding, bottom: Sizes.padding / 2, top: Sizes.padding / 2),
                        title: Text(
                          selectedFaqCategory!.faqs[index].question,
                          style: CLTheme.of(context).title,
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedFaqCategory!.faqs[index].answer,
                              style: CLTheme.of(context).bodyLabel,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ));
                },
              ),
            ),
          ])
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text("Seleziona una categoria", style: CLTheme.of(context).bodyLabel)],
          );
  }
}
