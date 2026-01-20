import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:she_secure/models/user_model.dart';
import 'package:she_secure/services/auth_service.dart';
import 'package:she_secure/services/database_service.dart';
import 'package:she_secure/widgets/custom_textfield.dart';

class ProfilePopup extends StatefulWidget {
  final UserModel user;

  const ProfilePopup({super.key, required this.user});

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isChanged = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    
    _nameController.addListener(_checkChanges);
    _passwordController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final nameChanged = _nameController.text.trim() != widget.user.fullName;
    final passwordEntered = _passwordController.text.isNotEmpty;
    
    final hasChanges = nameChanged || passwordEntered;
    
    if (hasChanges != _isChanged) {
      setState(() {
        _isChanged = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final dbService = DatabaseService();
      final authService = Provider.of<AuthService>(context, listen: false);
      
      bool nameUpdated = false;
      bool resetEmailSent = false;

      // 1. Update Name if changed
      if (_nameController.text.trim() != widget.user.fullName) {
        final updatedUser = UserModel(
          uid: widget.user.uid,
          email: widget.user.email,
          fullName: _nameController.text.trim(),
          role: widget.user.role,
          createdAt: widget.user.createdAt,
          profileImage: widget.user.profileImage,
          connectedDevices: widget.user.connectedDevices,
        );

        await dbService.updateUser(updatedUser);
        nameUpdated = true;
      }

      // 2. Send password reset email if password field was used
      if (_passwordController.text.isNotEmpty) {
        await authService.sendPasswordResetEmail(widget.user.email);
        resetEmailSent = true;
      }
      
      if (mounted) {
        String message = '';
        if (nameUpdated && resetEmailSent) {
          message = 'Profile updated & reset email sent!';
        } else if (nameUpdated) {
          message = 'Profile updated successfully';
        } else if (resetEmailSent) {
          message = 'Password reset email sent!';
        }

        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor,
                    backgroundImage: (widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty)
                        ? NetworkImage(widget.user.profileImage!)
                        : null,
                    child: (widget.user.profileImage == null || widget.user.profileImage!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      isRequired: true,
                      validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      prefixIcon: Icons.email_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      controller: _passwordController,
                      label: 'Request Password Reset',
                      hintText: 'Type anything to request reset mail',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isChanged && !_isLoading) ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
