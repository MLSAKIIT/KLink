import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:klink/profile/profile_page_view_model.dart';

class profile extends StatelessWidget {
  const profile({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileViewContent(),
    );
  }
}

class _ProfileViewContent extends StatefulWidget {
  const _ProfileViewContent({super.key});

  @override
  State<_ProfileViewContent> createState() => _ProfileViewContentState();
}

class _ProfileViewContentState extends State<_ProfileViewContent> {

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProfileViewModel>();
    vm.loadProfile('123'); // pass the actual user ID here
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF161616),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF161616),
      body:
          SingleChildScrollView(
           child: Container(
             child: Column(
                children: [
                Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.all(15),
                          backgroundColor: Color(0xFF383838)
                    ),
                      onPressed: () {

                      },
                      child: Icon(Icons.arrow_back,
                      color: Color(0xFFFFFFFF),
                      size: 25,
                      ),
                  ),
                  ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30, left: 32, right: 32),
                child: Container(
                  height: 109,
                  width: 366.3,
                  decoration: BoxDecoration(
                    color: Color(0xFF3D3D3D),
                    borderRadius: BorderRadius.circular(100)
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CircleAvatar(
                          radius: 54.5,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person),
                        ),
                      ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: ((20/998)*height), horizontal: ((10/448)*width)),
                            child: Container(
                              child: Column(
                                children: [
                                  Text(vm.followers, style: TextStyle(color: Colors.white, fontSize: 25)),
                                  Text("Followers", style: TextStyle(color: Color(0xFFA4A4A4)),)
                                ],
                              ),
                            ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: ((20/998)*height), horizontal: ((10/448)*width)),
                        child: Container(
                          child: Column(
                            children: [
                              Text(vm.posts, style: TextStyle(color: Colors.white, fontSize: 25)),
                              Text("Posts", style: TextStyle(color: Color(0xFFA4A4A4)),)
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: ((20/998)*height), horizontal: ((10/448)*width)),
                        child: Container(
                          child: Column(
                            children: [
                              Text(vm.following, style: TextStyle(color: Colors.white, fontSize: 25)),
                              Text("Following", style: TextStyle(color: Color(0xFFA4A4A4)),)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  width: width,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Positioned(
                            left: 0, top: 0,
                            child: Text(vm.username,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27
                              ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(vm.status,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF858585),
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                        SizedBox(
                        width: 37,
                        height: 37,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {},
                            child: Icon(Icons.edit,
                            size: 25)),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Container(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description",
                        style: TextStyle(
                          color: Color(0xFFACACAC),
                          fontSize: 17,
                          fontWeight: FontWeight.bold
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(vm.description,
                          style: TextStyle(
                              color: Color(0xFFACACAC),
                              fontSize: 17),),
                      ),
                    ],
                  ),
                ),
              ),




              // Tab Bar
              // Using a DefaultTabController for the 'Posts', 'Followers', 'Following' tabs
              DefaultTabController(
                length: 3, // Number of tabs
                child: Column(
                  children: [
                    // TabBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF000000), // Dark grey background for the tab bar
                          borderRadius: BorderRadius.circular(46),
                        ),
                        child: TabBar( // the inner tab - posts, followers or following
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(46),
                            color: Color(0xFFFFFFFF),
                          ),
                          labelColor: Colors.black, // Color of the selected tab label
                          unselectedLabelColor: Color(0xFF525252), // Color of unselected tab labels
                          labelStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'Posts'),
                            Tab(text: 'Followers'),
                            Tab(text: 'Following'),
                          ],
                        ),
                      ),
                    ),

                    // TabBarView content (needs to be inside an Expanded or have a fixed height)
                    SingleChildScrollView(
                    child: Container(
                      height: height, // Placeholder height, adjust as needed or wrap in Expanded
                      child: TabBarView(
                        children: [
                          // Posts Tab Content
                            Padding(padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: vm.userPosts.length,
                                  itemBuilder: (context, index) {
                                    final post = vm.userPosts[index];
                                    return _PostCommentTile(
                                      index: post['index'] ?? 0,
                                      username: post['username'] ?? '',
                                      comment: post['Text'] ?? '',
                                      isLiked: post['isLiked'] ?? false,
                                      isDisLiked: post['isDisLiked'] ?? false,
                                      onLikePressed: () => vm.toggleLike(index),
                                      onDisLikePressed: () => vm.toggleDisLike(index),
                                    );
                                  },
                                ),
                              ],
                            ),
                            ),

                          // Followers Tab Content (Placeholder)
                          Center(
                              child: Text('Followers List',
                                  style: TextStyle(color: Colors.white))),

                          // Following Tab Content (Placeholder)
                          Center(
                              child: Text('Following List',
                                  style: TextStyle(color: Colors.white))),
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
              ),
                       ],
                     ),
           ),
    ),
    );
  }




  // A Widget for the post tile
  Widget _PostCommentTile({
    required int index,
    required String username,
    required String comment,
    required bool isLiked,
    required bool isDisLiked,
    required VoidCallback onLikePressed,
    required VoidCallback onDisLikePressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Card(
        color: Colors.black,
        // Change the immediate child to a Column to stack the header and content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER ROW: Avatar, Username, and Delete Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // User Avatar
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  const SizedBox(width: 10),

                  // Username (Expanded to take available space)
                  Expanded(
                    child: Text(
                      username,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Delete Button
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF383838),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                      onPressed: () {},
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),

            // Add a space between the header and the comment body
            const SizedBox(height: 10),

            // 2. CONTENT COLUMN: Comment and Action Buttons
            Padding(
              // Add horizontal padding if needed, or leave it to the outer Padding
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment Text
                  Text(
                    comment,
                    style: const TextStyle(color: Color(0xFFA4A4A4), fontSize: 14),
                    overflow: TextOverflow.clip,
                  ),
                  const SizedBox(height: 5),
                  const Divider(color: Color(0xFF454545), thickness: 1, height: 15),

                  // Type Something... & Like/Dislike Buttons
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Type Something....',
                          style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF383838),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: IconButton(
                                onPressed: onLikePressed,
                                icon: Icon(
                                    isLiked ? Icons.thumb_up: Icons.thumb_up_outlined,
                                  color: Color(0xFFF0F0F0), size: 20),
                            ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF383838),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: IconButton(
                                onPressed: onDisLikePressed,
                                  icon: Icon(
                                      isDisLiked ? Icons.thumb_down: Icons.thumb_down_alt_outlined ,
                                  color: Color(0xFFF0F0F0), size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

} // End of _profileState class
