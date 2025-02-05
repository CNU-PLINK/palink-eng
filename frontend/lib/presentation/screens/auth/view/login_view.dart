import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/presentation/screens/auth/controller/login_view_model.dart';

import 'package:palink_v2/presentation/screens/auth/view/signup_view.dart';
import 'package:palink_v2/presentation/screens/common/custom_btn.dart';
import 'package:sizing/sizing.dart';

class LoginView extends StatelessWidget {
  final LoginViewModel loginViewModel = getIt<LoginViewModel>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController memberIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 5),
              Text(
                'Welcome 🎉',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              SizedBox(height: 0.05.sh),
              _buildTextField(
                controller: memberIdController,
                labelText: 'User ID',
                hintText: 'Enter your user ID.',
              ),
              SizedBox(height: 0.02.sh),
              _buildTextField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password.',
                isObscure: true,
              ),
              SizedBox(height: 0.17.sh),
              Center(
                child: Obx(() {
                  // Obx observes the Rx variable state.
                  return CustomButton(
                    label: loginViewModel.isLoading.value ? 'Logging in...' : 'Login',
                    onPressed: () {
                      loginViewModel.login(
                        memberIdController.text,
                        passwordController.text,
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: 0.02.sh),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.to(() => SignupView());
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            hintText: hintText,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
