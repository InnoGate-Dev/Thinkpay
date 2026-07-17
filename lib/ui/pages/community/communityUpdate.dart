import 'package:Thinkpay/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityUpdatePage extends StatefulWidget {
  const CommunityUpdatePage({super.key});

  @override
  State<CommunityUpdatePage> createState() => _CommunityUpdatePageState();
}

class _CommunityUpdatePageState extends State<CommunityUpdatePage> {
  // Mock data for followed channels
  final List<Channel> followedChannels = [
    Channel(
      name: 'Investing 101',
      lastMessage: 'Here are top 5 ETFs for 2026 📈',
      time: '10:45 AM',
      unreadCount: 3,
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      isVerified: true,
    ),
    Channel(
      name: 'Tech & Finance',
      lastMessage: 'Apple just announced new features...',
      time: 'Yesterday',
      unreadCount: 0,
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      isVerified: true,
    ),
    Channel(
      name: 'Startup Founders',
      lastMessage: 'How to pitch to VCs effectively',
      time: 'Monday',
      unreadCount: 5,
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      isVerified: false,
    ),
  ];

  // Mock data for suggested channels
  final List<Channel> exploreChannels = [
    Channel(
      name: 'Real Estate Hub',
      followersCount: '1.2M followers',
      avatarUrl: 'https://i.pravatar.cc/150?img=21',
      isVerified: true,
    ),
    Channel(
      name: 'Daily Crypto',
      followersCount: '850K followers',
      avatarUrl: 'https://i.pravatar.cc/150?img=22',
      isVerified: false,
    ),
    Channel(
      name: 'Personal Finance',
      followersCount: '2.5M followers',
      avatarUrl: 'https://i.pravatar.cc/150?img=23',
      isVerified: true,
    ),
    Channel(
      name: 'Stock Market',
      followersCount: '500K followers',
      avatarUrl: 'https://i.pravatar.cc/150?img=24',
      isVerified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Channels Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.sm,
              ),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Text(
                    'Community',
                    style: GoogleFonts.manrope(
                      color: colors.text100,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

            ),

            // Followed Channels List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: followedChannels.length,
              itemBuilder: (context, index) {
                return _ChannelListTile(channel: followedChannels[index]);
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.sm,
              ),
              child: Divider(color: colors.divider),
            ),

            // Find Channels Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Find channels',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.text100,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'See all',
                      style: AppTypography.bodySm.copyWith(
                        color: colors.coreAction,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Horizontal Explore Channels
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                itemCount: exploreChannels.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _ExploreChannelCard(channel: exploreChannels[index]),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ChannelListTile extends StatelessWidget {
  final Channel channel;

  const _ChannelListTile({required this.channel});

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(channel.avatarUrl),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          channel.name,
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.text100,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (channel.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          color: colors.coreAction,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel.lastMessage ?? '',
                    style: AppTypography.bodyMd.copyWith(color: colors.text70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Trailing
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (channel.time != null)
                  Text(
                    channel.time!,
                    style: AppTypography.bodySm.copyWith(
                      color: (channel.unreadCount ?? 0) > 0
                          ? colors.coreAction
                          : colors.text40,
                      fontWeight: (channel.unreadCount ?? 0) > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                const SizedBox(height: 6),
                if ((channel.unreadCount ?? 0) > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.coreAction,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${channel.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreChannelCard extends StatelessWidget {
  final Channel channel;

  const _ExploreChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(channel.avatarUrl),
              ),
              if (channel.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      color: colors.coreAction,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            channel.name,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.text100,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            channel.followersCount ?? '',
            style: AppTypography.bodySm.copyWith(
              color: colors.text70,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.limeDim,
                foregroundColor: colors.coreAction,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Follow',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Channel {
  final String name;
  final String? lastMessage;
  final String? time;
  final int? unreadCount;
  final String? followersCount;
  final String avatarUrl;
  final bool isVerified;

  Channel({
    required this.name,
    this.lastMessage,
    this.time,
    this.unreadCount,
    this.followersCount,
    required this.avatarUrl,
    required this.isVerified,
  });
}
