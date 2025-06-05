import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masrtiongapi/cubit/user_cubit.dart';
import 'package:masrtiongapi/cubit/user_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is GetUserFailure) {
          _showSnackBar(context, state.errorMessage);
        }
        if (state is UpDateUserDataFailure) {
          _showSnackBar(context, state.errorMessage);
        }
        if (state is UpDateUserDataSuccess) {
          _showSnackBar(context, state.updateDataModel.message);
          context.read<UserCubit>().clearUpdateFields();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile'), centerTitle: true),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserState state) {
    if (state is GetUserLoading || state is UpDateUserDataLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GetUserFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<UserCubit>().getUserProfile(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is GetUserSuccess) {
      return RefreshIndicator(
        onRefresh: () => context.read<UserCubit>().getUserProfile(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfilePicture(state.user.profilePic),
            const SizedBox(height: 24),
            _buildNameField(context, state),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.email, 'Email', state.user.email),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.phone, 'Phone', state.user.phone),
            const SizedBox(height: 16),
            _buildInfoTile(
              Icons.location_city,
              'Address',
              state.user.adress['type'],
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildProfilePicture(String imageUrl) {
    return Center(
      child: CircleAvatar(
        radius: 80,
        backgroundImage: NetworkImage(imageUrl),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context, GetUserSuccess state) {
    final cubit = context.read<UserCubit>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.person, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: cubit.upDateName,
                decoration: InputDecoration(
                  hintText: state.user.name,
                  border: InputBorder.none,
                  errorText: state is UpDateUserDataFailure
                      ? 'Update failed'
                      : null,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    cubit.upDateUserData();
                  }
                },
              ),
            ),
            if (cubit.upDateName.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  cubit.upDateName.clear();
                  cubit.emit(GetUserSuccess(user: state.user));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
