import 'package:flutter/material.dart';
import 'package:weather_app/controllers/forecast_controller.dart';
import 'package:weather_app/utils/forecast_animation_utils.dart';

class TimePickerRow extends StatefulWidget {
  final List<String> tabItems;//has the list of time intervals to be picked from
  final ForecastController forecastController;//fetches the forecast data
  final Function onTabChange;//callback to notify the parent on changes on the tab
  final int startIndex;//current tab by default

  const TimePickerRow({
    Key key,
    this.forecastController,
    this.tabItems,
    this.onTabChange,
    this.startIndex,
  }) : super(key: key);

  @override
  _TimePickerRowState createState() => _TimePickerRowState();
}

class _TimePickerRowState extends State<TimePickerRow> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(//it must know how many tabs will exist
      length: AnimationUtil.hours.length,
      vsync: this,
      initialIndex: widget.startIndex,
    );
    _tabController.addListener(handleTabChange);
    super.initState();
  }

  void handleTabChange() {
    if (_tabController.indexIsChanging) return;//check to prevent an event to start in the
    // middle of an animation
    widget.onTabChange(_tabController.index);
  }
  //int activeTab;
  //void _handleTabChange() {
    //setState(() => this.activeTab = _tabController.index); }

  @override
  void didUpdateWidget(TimePickerRow oldWidget) {
    _tabController.animateTo(widget.startIndex);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelColor: Colors.black,//configuration defining styles
      unselectedLabelColor: Colors.black38,
      unselectedLabelStyle: Theme.of(context).textTheme.caption.copyWith(fontSize: 10.0),
      labelStyle: Theme.of(context).textTheme.caption.copyWith(fontSize: 12.0),
      indicatorColor: Colors.transparent,
      labelPadding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
      controller: _tabController,//controller passed from the parent
      tabs: widget.tabItems.map((t) => Text(t)).toList(),// tab items from the forecast page
      // are iterated through into Text widgets
      isScrollable: true,// not the default of tabs though
    );
  }
}
