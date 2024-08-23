import 'package:chat_app/Controller/ContactController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Controller/chattcontroller.dart';
import 'package:chat_app/Pages/CallHistory/callHistory.dart';
import 'package:chat_app/Pages/Chat/ChatPage.dart';
import 'package:chat_app/Pages/Groups/GroupsPage.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:chat_app/Pages/Home/Widget/ChatsList.dart';
import 'package:chat_app/Pages/Home/Widget/TabBar.dart';
import 'package:chat_app/Pages/Home/Widget/userSearchBar.dart';
import 'package:chat_app/Pages/ProfilePage/ProfilePage.dart';
import 'package:chat_app/config/Images.dart';
import 'package:chat_app/config/String.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final RxBool isSearchEnable = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(length: 3, vsync: this);
    final ProfileController profileController = Get.put(ProfileController());
    final ContactController contactController = Get.put(ContactController());
    Get.lazyPut(() => ChattController());

    // Ensure currentUser is not null before accessing uid
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Obx(
          () => isSearchEnable.value
              ? UserSearchBar(
                  searchController: searchController,
                  onChanged: (val) {
                    contactController.searchUsers(val);
                  },
                )
              : Text(
                  AppString.appName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            AssetsImage.appIconSVG,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchEnable.value = !isSearchEnable.value;
                if (!isSearchEnable.value) {
                  searchController.clear();
                  contactController.searchUsers('');
                }
              });
            },
            icon: Icon(isSearchEnable.value ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () async {
              await profileController.getUserDetails();
              Get.to(const ProfilePage());
            },
            icon: const Icon(
              Icons.more_vert,
            ),
          )
        ],
        bottom: myTabBar(tabController, context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed("/contactPage");
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: TabBarView(
          controller: tabController,
          children: [
            Obx(
              () {
                // Check if filteredUserList is not null
                final users = contactController.filteredUserList;

                return isSearchEnable.value
                    ? ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          var user = users[index];

                          // Handle null values with fallback defaults
                          return InkWell(
                            onTap: () {
                              Get.to(ChatPage(userModel: user));
                            },
                            child: ChatTile(
                              imageUrl: (user.profileImage?.isNotEmpty ?? false)
                                  ? user.profileImage!
                                  : AssetsImage.defaultProfileUrl,
                              name: user.name ?? 'User',
                              lastChat: (user.about?.isNotEmpty ?? false)
                                  ? user.about!
                                  : 'Hey, I am using Sampark App!',
                              lastTime: '',
                              roomId: '',
                              isCurrentUser: user.id == currentUserId,
                            ),
                          );
                        },
                      )
                    : const ChatList();
              },
            ),
            const GroupPage(),
            const CallHistory(),
          ],
        ),
      ),
    );
  }
}
