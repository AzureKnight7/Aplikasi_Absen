import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_attandance/src/presentation/auth/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const _Initial()) {
    on<_Login>((event, emit) async {
      emit(const AuthState.loading());
      var services = AuthServices();
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Lakukan login
      var loginData =
          await services.doLogin(email: event.email, password: event.password);
      await loginData.fold((l) async {
        emit(AuthState.failed(errorMessage: l));
      }, (r) async {
        // Ambil token dari hasil login
        String token = r['token'];
        await prefs.setString(
            'token', token); // Simpan token di SharedPreferences

        // Gunakan token untuk mendapatkan data pengguna
        var userData = await services.getUserById(token);
        await userData.fold((l) async {
          emit(AuthState.failed(errorMessage: l)); // Emit error jika gagal
        }, (user) async {
          // Emit state authenticated jika berhasil
          String name = user['fullName'];
          String email = user['email'];
          String profile = user['userId'];

          emit(AuthState.authenticate(
              name: name, email: email, profile: profile));
        });
      });
    });

    on<_Register>((event, emit) async {
      emit(const AuthState.loading());
      var services = AuthServices();
      var data = await services.doRegister(
        name: event.username,
        email: event.email,
        password: event.password,
        tanggalLahir: event.birtdays,
        alamat: event.address,
        nomorTelp: event.noTelp,
      );
      data.fold((l) {
        emit(AuthState.failed(errorMessage: l));
      }, (r) {
        emit(const AuthState.successRegister());
      });
    });

    on<_Logout>((event, emit) async {
      emit(const AuthState.loading());
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Hapus token saat logout
      emit(const AuthState.unauthenticate());
    });
  }
}
