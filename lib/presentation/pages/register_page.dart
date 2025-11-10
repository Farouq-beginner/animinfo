import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_center_layout.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      // TAMBAHKAN: AppBar
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationAuthenticated) {
            context.go('/main');
          } else if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // BUNGKUS: dengan SingleChildScrollView
        child: SingleChildScrollView(
          child: ResponsiveCenterLayout(
            // BUNGKUS: dengan ResponsiveCenterLayout
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Form(
                key: _formKey,
                child: Column(
                  // UBAH: mainAxisAlignment
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TAMBAHKAN: Spasi dari atas
                    SizedBox(height: 10.h),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    CustomTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      builder: (context, state) {
                        if (state is AuthenticationLoading) {
                          return const CircularProgressIndicator();
                        }
                        return CustomButton(
                          text: 'Register',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthenticationBloc>().add(
                                RegisterEvent(
                                  username: _usernameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 2.h),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h), // Spasi di bawah
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
