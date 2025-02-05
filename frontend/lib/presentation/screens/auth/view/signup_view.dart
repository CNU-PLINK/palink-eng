import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/presentation/screens/auth/controller/signup_view_model.dart';
import 'package:palink_v2/presentation/screens/common/custom_btn.dart';
import 'package:sizing/sizing.dart';
import 'package:flutter/services.dart';

class SignupView extends StatelessWidget {
  final SignupViewModel signupViewModel = getIt<SignupViewModel>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController memberIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController personalityTypeController =
        TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Sign Up', style: textTheme().titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (signupViewModel.errorMessage.value.isNotEmpty) {
            return Center(
                child: Text('Error: ${signupViewModel.errorMessage.value}'));
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                    controller: memberIdController,
                    labelText: 'User ID',
                    hintText: 'Enter your user ID.',
                  ),
                  SizedBox(height: 0.03.sh),
                  _buildTextField(
                    controller: nameController,
                    labelText: 'User Name',
                    hintText: 'Enter your name.',
                  ),
                  SizedBox(height: 0.03.sh),
                  _buildTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password.',
                    isObscure: true,
                  ),
                  SizedBox(height: 0.03.sh),
                  _buildTextField(
                    controller: ageController,
                    labelText: 'Age',
                    hintText: 'Enter your age.',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 0.1.sh),
                  CustomButton(
                    label: signupViewModel.isLoading.value
                        ? 'Signing up...'
                        : 'Sign Up',
                    onPressed: () {
                      signupViewModel.signUp(
                        memberIdController.text,
                        passwordController.text,
                        nameController.text,
                        int.tryParse(ageController.text) ?? 0,
                        personalityTypeController.text,
                      );
                    },
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff134f91)),
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
