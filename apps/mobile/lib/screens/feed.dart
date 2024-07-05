import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glyph/components/heading.dart';
import 'package:glyph/components/pressable.dart';
import 'package:glyph/context/bottom_menu.dart';
import 'package:glyph/ferry/widget.dart';
import 'package:glyph/graphql/__generated__/feed_screen_query.req.gql.dart';
import 'package:glyph/icons/tabler.dart';
import 'package:glyph/icons/tabler_bold.dart';
import 'package:glyph/providers/auth.dart';
import 'package:glyph/routers/app.gr.dart';
import 'package:glyph/shells/default.dart';
import 'package:glyph/themes/colors.dart';

@RoutePage()
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  bool _showBottomBorder = false;

  final req = GFeedScreen_QueryReq((b) => b..requestId = 'FeedScreen_Query');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = ref.read(authProvider);
      final onboardingCompleted =
          auth.requireValue.whenOrNull(authenticated: (accessToken, me) => me.onboardingCompleted);

      if (onboardingCompleted != true) {
        await context.router.push(const OnboardingCurationRoute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLOperation(
      operation: req,
      builder: (context, client, data) {
        final notificationCount = data.me?.notificationCount ?? 0;

        return AutoTabsRouter(
          routes: const [
            FeedRecommendRoute(),
            FeedFollowingRoute(),
            FeedChallengeRoute(),
          ],
          transitionBuilder: (context, child, animation) => child,
          builder: (context, child) {
            final tabsRouter = AutoTabsRouter.of(context);
            return DefaultShell(
              appBar: Heading(
                bottomBorder: _showBottomBorder,
                leading: Pressable(
                  child: Row(
                    children: [
                      Text(
                        switch (tabsRouter.activeIndex) {
                          0 => '추천',
                          1 => '구독',
                          2 => '챌린지',
                          _ => throw UnimplementedError(),
                        },
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(4),
                      const Icon(TablerBold.chevron_down, size: 16),
                    ],
                  ),
                  onPressed: () async {
                    await context.showBottomSelectMenu(
                      title: '피드',
                      value: tabsRouter.activeIndex,
                      items: [
                        BottomSelectMenuItem(label: '추천', value: 0),
                        BottomSelectMenuItem(label: '구독', value: 1),
                        BottomSelectMenuItem(label: '챌린지', value: 2),
                      ],
                      onSelected: (value) {
                        tabsRouter.setActiveIndex(value);
                      },
                    );
                  },
                ),
                actions: [
                  if (tabsRouter.activeIndex == 1) ...[
                    Pressable(
                      child: const Icon(Tabler.settings),
                      onPressed: () async {
                        await context.router.push(
                          WebViewRoute(
                            title: '구독 설정',
                            path: '/me/subscribes',
                          ),
                        );
                      },
                    ),
                    const Gap(20),
                  ],
                  Pressable(
                    // child: const Icon(Tabler.bell),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Tabler.bell),
                        if (notificationCount > 0)
                          Positioned(
                            left: 12,
                            top: -1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                              decoration: BoxDecoration(
                                color: BrandColors.brand_600,
                                border: Border.all(color: BrandColors.gray_0),
                                borderRadius: const BorderRadius.all(Radius.circular(100)),
                              ),
                              child: Text(
                                notificationCount <= 99 ? '$notificationCount' : '99+',
                                style: const TextStyle(
                                  color: BrandColors.gray_0,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () async {
                      await context.router.push(
                        const NotificationRoute(),
                      );
                    },
                  ),
                ],
              ),
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  final showBottomBorder = notification.metrics.pixels > 0;
                  if (showBottomBorder != _showBottomBorder) {
                    setState(() {
                      _showBottomBorder = showBottomBorder;
                    });
                  }

                  return false;
                },
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
