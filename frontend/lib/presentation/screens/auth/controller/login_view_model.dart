import 'package:get/get.dart';
import 'package:palink_v2/domain/model/auth/login_model.dart';
import 'package:palink_v2/domain/model/user/user.dart';
import 'package:palink_v2/domain/usecase/login_usecase.dart';
import 'package:palink_v2/presentation/screens/main_screens.dart';

class LoginViewModel extends GetxController {
  final LoginUseCase loginUseCase;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var user = Rxn<User>();

  LoginViewModel({required this.loginUseCase});

  Future<void> login(String accountId, String password) async {
    if (accountId.isEmpty || password.isEmpty) {
      _showError('Please enter your ID and password!');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await loginUseCase
          .execute(LoginModel(accountId: accountId, password: password));
      if (result != null) {
        user.value = result;
        Get.off(() => const MainScreens());
      } else {
        _showError('Login failed.');
      }
    } catch (e) {
      _showError('Login failed. $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar('Error', message, snackPosition: SnackPosition.TOP);
  }
}
