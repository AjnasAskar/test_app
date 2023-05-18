import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auths/common/consts.dart';
import 'package:firebase_auths/view/authentication/auth_screen.dart';
import 'package:firebase_auths/view_model/auth_view_model.dart';
import 'package:firebase_auths/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../model/product_data_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Stack(
            children: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.shopping_cart)),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Selector<HomeViewModel, Map<String, CategoryDishes?>>(
                    selector: (context, provider) => provider.cartList,
                    builder: (context, value, child) {
                      return Text(
                        '${value.keys.length}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      );
                    },
                  ),
                ),
              )
            ],
          )
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF709539), Colors.lightGreen])),
              child: _DrawerHeader()),
          ListTile(
            onTap: () {
              context.read<AuthViewModel>().logoutUser(
                  context: context,
                  onSuccess: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false);
                  });
            },
            leading: Icon(
              Icons.logout,
              color: Colors.grey.shade800,
            ),
            title: Text(
              'Log out',
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          )
        ],
      ),
      body: const _HomeView(),
    );
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<HomeViewModel>().getHomeData();
    });
    super.initState();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, provider, child) {
        if (provider.loadState == LoadState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return DefaultTabController(
            length: provider.productDataModel?.tableMenuList?.length ?? 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: List.generate(
                        provider.productDataModel?.tableMenuList?.length ?? 0,
                        (index) => Tab(
                              text: provider.productDataModel
                                      ?.tableMenuList?[index].menuCategory ??
                                  '',
                            ))),
                Expanded(
                    child: TabBarView(
                        children: List.generate(
                            provider.productDataModel?.tableMenuList?.length ??
                                0, (index) {
                  List<CategoryDishes> categoryDishes = provider
                          .productDataModel
                          ?.tableMenuList?[index]
                          .categoryDishes ??
                      [];
                  return ListView.separated(
                      itemBuilder: (context, subIndex) => _ProductCardTile(
                            categoryDishes: categoryDishes[subIndex],
                          ),
                      separatorBuilder: (_, __) => Container(
                            height: 1,
                            width: double.maxFinite,
                            color: Colors.black12,
                          ),
                      itemCount: categoryDishes.length);
                })))
              ],
            ));
      },
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<AuthViewModel, User?>(
      selector: (context, provider) => provider.user,
      builder: (context, value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl:
                      value?.photoURL ?? "http://via.placeholder.com/350x150",
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              value?.displayName ?? '---',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (value?.tenantId != null)
              Text(
                "ID: ${value!.tenantId}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              )
          ],
        );
      },
    );
  }
}

class _ProductCardTile extends StatelessWidget {
  final CategoryDishes? categoryDishes;
  const _ProductCardTile({Key? key, this.categoryDishes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.only(left: 5, top: 5),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryDishes?.dishName ?? ''),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text(categoryDishes?.price ?? '')),
                      Text('${categoryDishes?.dishCalories ?? 0} calories'),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(categoryDishes?.dishDescription ?? ''),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.green),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  context
                                      .read<HomeViewModel>()
                                      .removeFromCartList(
                                          id: categoryDishes?.dishId ?? '',
                                          categoryDishes: categoryDishes);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.remove,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Selector<HomeViewModel,
                                    Map<String, CategoryDishes?>>(
                                  selector: (context, provider) =>
                                      provider.cartList,
                                  builder: (context, value, child) {
                                    return Text(
                                      (value[categoryDishes?.dishId ?? '']
                                                  ?.quantity ??
                                              0)
                                          .toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.read<HomeViewModel>().addToCartList(
                                      id: categoryDishes?.dishId ?? '',
                                      categoryDishes: categoryDishes);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((categoryDishes?.addonCat ?? []).isNotEmpty)
                    const Text(
                      "Customization available",
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 70,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: categoryDishes?.dishImage ??
                    "http://via.placeholder.com/350x150",
                placeholder: (context, url) => Container(
                  color: Colors.black12,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          )
        ],
      ),
    );
  }
}
