import 'package:bloc/bloc.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/networking.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.init());

  bool _userValid(String user) {
    return true;
  }

  bool _passValid(String pass) {
    return true;
  }

  _submitLogin(String user, String pass, bool stayLoggedIn) async {
    bool connected = await isConnected();

    if (!connected) {
      add(LoginFailed(otherError: loc.getText(loc.noInternet)));
      return;
    }

    add(LoginSucceed(stayLoggedIn));
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is FormSubmitEvent) {
      FormSubmitEvent submitEvent = event as FormSubmitEvent;

      if (!_userValid(submitEvent.user)) {
        yield LoginState.failed(userError: loc.getText(loc.invalidUsername));
      }

      if (!_passValid(submitEvent.pass)) {
        yield LoginState.failed(
            passError: loc.getText(loc.invalidPassword),
            otherError: loc.getText(loc.correctPass));
      }

      _submitLogin(
        submitEvent.user,
        submitEvent.pass,
        submitEvent.stayLoggedIn,
      );

      yield LoginState.load();
    }
  }
}

abstract class LoginEvent {
  const LoginEvent();
}

class FormSubmitEvent {
  final String user, pass;
  final bool stayLoggedIn;

  const FormSubmitEvent(this.user, this.pass, this.stayLoggedIn);
}

class LoginSucceed extends LoginEvent {
  final bool stayLoggedIn;

  const LoginSucceed(this.stayLoggedIn);
}

class LoginFailed extends LoginEvent {
  final String? userError, passError, otherError;

  const LoginFailed({
    this.userError,
    this.passError,
    this.otherError,
  });
}

class LoginState {
  final bool initial, loading, succeed;
  final String? userError, passError, otherError;

  const LoginState({
    this.loading = false,
    this.initial = false,
    this.succeed = false,
    this.userError,
    this.passError,
    this.otherError,
  });

  factory LoginState.success() => const LoginState(succeed: true);

  factory LoginState.failed({
    String? userError,
    String? passError,
    String? otherError,
  }) {
    return LoginState(
      succeed: false,
      otherError: otherError,
      userError: userError,
      passError: passError,
    );
  }

  factory LoginState.init() => const LoginState(initial: true);

  factory LoginState.load() => const LoginState(loading: true);
}
