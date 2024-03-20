import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderBoardScreen extends StatefulWidget {
  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _userSnapshot = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchUsers();
  }

  void _fetchUsers() async {
    try {
      // Fetch users sorted by XP
      QuerySnapshot statsSnapshot =
          await FirebaseFirestore.instance.collection('Stats').get();

      // Extract UID and XP data from the Stats collection
      Map<String, int> xpData = {};
      for (var doc in statsSnapshot.docs) {
        xpData[doc.id] = (doc.data() as Map<String, dynamic>)['xp'];
      }

      // Fetch user names from the 'users' collection
      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Merge user names with XP data
      List<Map<String, dynamic>> users = [];
      for (var userDoc in userSnapshot.docs) {
        String uid = userDoc.id;
        String name = (userDoc.data() as Map<String, dynamic>)['name'];
        int xp = xpData[uid] ?? 0; // Default to 0 if XP data is not found
        users.add({
          'uid': uid,
          'name': name,
          'xp': xp,
        });
      }
      users.sort((a, b) => b['xp'].compareTo(a['xp']));

      setState(() {
        _userSnapshot = users;
      });
    } catch (error) {
      print('Error fetching users: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(
                    () {}); // Trigger rebuild to update the filtered user list
              },
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    // Filtered user list based on search query
    List<Map<String, dynamic>> filteredUsers = _userSnapshot.where((user) {
      String name = user['name'] ?? '';
      return name.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
    print(filteredUsers);
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var userData = filteredUsers[index];

        return ListTile(
          title: Text(userData['name'] ?? ''),
          subtitle: Text('XP: ${userData['xp'] ?? ''}'),
          // Implement more user details here
        );
      },
    );
  }
}
