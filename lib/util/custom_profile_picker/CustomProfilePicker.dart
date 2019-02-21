import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/CustomProfileBloc.dart';
import 'package:hokollektor/home/Home.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/custom_profile_picker/SliderPicker.dart';

class CustomProfilePicker extends StatelessWidget {
  final CustomProfileBloc bloc;

  const CustomProfilePicker({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Material(
          borderRadius: appBorderRadius,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: BlocBuilder<CustomProfileEvent, CustomProfileState>(
                bloc: bloc,
                builder: _buildLayout,
              )),
        ),
      ),
    );
  }

  _getDropdownValue(bool expanded) {
    return expanded ? loc.getText(loc.expanded) : loc.getText(loc.simplified);
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
              if (value != state.expanded && !state.loading)
                bloc.dispatch(SizeChangedEvent(value));
            }),
        state.loading
            ? CircularProgressIndicator()
            : state.expanded
                ? SliderPicker(
                    values: state.values,
                    onChanged: (value) => bloc.dispatch(ValueChangeEvent(
                        expanded: value.length == expandedSize,
                        initial: false,
                        newValues: value)),
                    diffBetweenElements: 10,
                    numItems: 10,
                  )
                : SliderPicker(
                    values: state.values,
                    onChanged: (value) => bloc.dispatch(ValueChangeEvent(
                        expanded: value.length == expandedSize,
                        initial: false,
                        newValues: value)),
                    diffBetweenElements: 25,
                    numItems: 5,
                  ),
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            OutlineButton(
                child: Text(loc.getText(loc.cancel)),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(borderRadius: appBorderRadius),
                textColor: Theme.of(context).primaryColor,
                onPressed: () => Navigator.pop(context)),
            RaisedButton(
              child: Text(loc.getText(loc.save)),
              shape: RoundedRectangleBorder(borderRadius: appBorderRadius),
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                if (!state.loading) Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
