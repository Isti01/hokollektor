import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/CustomProfileBloc.dart';
import 'package:hokollektor/util/custom_profile_picker/SliderPicker.dart';

class CustomProfilePicker extends StatelessWidget {
  final CustomProfileBloc bloc;

  const CustomProfilePicker({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Material(
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              child: BlocBuilder<CustomProfileEvent, CustomProfileState>(
                bloc: bloc,
                builder: _buildLayout,
              )),
        ),
      ),
    );
  }

  _getDropdownValue(bool expanded) {
    return expanded ? 'Expnaded' : 'Simplified';
  }

  Widget _buildLayout(BuildContext context, CustomProfileState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DropdownButton<bool>(
            value: state.expanded,
            items: [
              DropdownMenuItem(
                child: Text(_getDropdownValue(true)),
                value: true,
              ),
              DropdownMenuItem(
                child: Text(_getDropdownValue(false)),
                value: false,
              )
            ],
            onChanged: (value) {
              if (value != state.expanded)
                bloc.dispatch(SizeChangedEvent(value));
            }),
        state.expanded
            ? ExpandedSliderPicker(
                values: state.values,
                onChanged: (value) => print('changed $value'),
              )
            : MinifiedSliderPicker(
                values: state.values,
                onChanged: (value) => print('changed $value'),
              ),
      ],
    );
  }
}
