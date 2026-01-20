import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/services/auth_service.dart';
import 'package:she_secure/utils/validators.dart';
import 'package:she_secure/widgets/custom_button.dart';
import 'package:she_secure/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // Success - automatically login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Registration Failed'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                SizedBox(height: 20),
                Text(
                  'Join SheSecure',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),

                // Full Name
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person,
                  validator: Validators.name,
                ),
                SizedBox(height: 20),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),

                // Phone
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                SizedBox(height: 20),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons
                          .visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                SizedBox(height: 20),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons
                          .visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                SizedBox(height: 30),

                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                      activeColor: Theme
                          .of(context)
                          .primaryColor,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(color: Colors.grey[700]),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Register Button
                CustomButton(
                  onPressed: _isLoading ? null : _register,
                  text: _isLoading ? 'Creating Account...' : 'Create Account',
                  isLoading: _isLoading,
                ),
                SizedBox(height: 20),

                // Already have account
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
