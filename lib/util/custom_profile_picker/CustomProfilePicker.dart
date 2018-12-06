import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/CustomProfileBloc.dart';
import 'package:hokollektor/util/custom_profile_picker/SliderPicker.dart';

class CustomProfilePicker extends StatelessWidget {
  final CustomProfileBloc bloc;

  const CustomProfilePicker({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.0, -0.5),
      child: SingleChildScrollView(
        child: Material(
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: BlocBuilder<CustomProfileEvent, CustomProfileState>(
                bloc: bloc,
                builder: _buildLayout,
              )),
        ),
      ),
    );
  }

  _getDropdownValue(bool expanded) {
    return expanded ? 'Expanded' : 'Simplified';
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
                ? ExpandedSliderPicker(
                    values: state.values,
                    onChanged: (value) => bloc.dispatch(ValueChangeEvent(
                        expanded: value.length == expandedSize,
                        initial: false,
                        newValues: value)),
                  )
                : MinifiedSliderPicker(
                    values: state.values,
                    onChanged: (value) => bloc.dispatch(ValueChangeEvent(
                        expanded: value.length == expandedSize,
                        initial: false,
                        newValues: value)),
                  ),
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            OutlineButton(
                child: Text('Cancel'),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                textColor: Theme.of(context).primaryColor,
                onPressed: () => Navigator.pop(context)),
            RaisedButton(
              child: Text('Save'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
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
