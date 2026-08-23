import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/constant/theme_provider.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
// Note: Adjust these page imports based on where your app handles main chat sessions
import 'package:Thinkpay/ui/pages/profile/Profile.dart';

class ChathistoryDrawer extends StatelessWidget {
  const ChathistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ThemeColors.of(context).background,
      child: ListenableBuilder(
        listenable: Listenable.merge([ThemeNotifier(), UserProfileStore()]),
        builder: (context, _) {
          final tc = ThemeColors.of(context);
          final store = UserProfileStore();

          // Mock Data: In a real app, bind this to a ChatHistoryProvider/Store
          final recentChats = [
            {"id": "1", "title": "Expense Tracking Help", "time": "10m ago"},
            {"id": "2", "title": "Crypto Investment Advice", "time": "2h ago"},
            {"id": "3", "title": "Budget Analysis Q2", "time": "Yesterday"},
            {"id": "4", "title": "Tax Deductions 2026", "time": "3 days ago"},
          ];
          const activeChatId = "1"; // Highlight current active conversation

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Drawer Header: User Info ─────────────────────────────
                _buildHeader(context, tc, store),

                // ── Action: New Chat Button ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement logic to clear active chat state and open empty canvas
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: tc.limeDim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tc.limeBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: tc.lime, size: 20),
                          const SizedBox(width: 8),
                          Text('New Chat',
                              style: TextStyle(color: tc.lime, fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Main Section: Chat History List ───────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                        key: const ValueKey('HistoryHeader'),
                        child: Text('RECENT CHATS',
                            style: TextStyle(color: tc.text40, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                      ),

                      _ChatGroup(
                        tc: tc,
                        items: recentChats.map((chat) {
                          final isSelected = chat['id'] == activeChatId;
                          return _ChatItem(
                            title: chat['title']!,
                            time: chat['time']!,
                            isSelected: isSelected,
                            tc: tc,
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Trigger chat session switch via your State Management
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── Footer Actions: Clean / Manage History ────────────────
                _buildFooterActions(context, tc),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeColors tc, UserProfileStore store) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tc.cardGradientStart, tc.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: tc.border)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tc.surface2,
            border: Border.all(color: tc.border, width: 1.5),
          ),
          child: Icon(Icons.psychology_rounded, color: tc.text100, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Thinkpay AI',
                style: TextStyle(color: tc.text100, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(store.name,
                style: TextStyle(color: tc.text40, fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ]),
        ),
        IconButton(
          icon: Icon(Icons.account_circle_outlined, color: tc.text70),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile()));
          },
        )
      ]),
    );
  }

  Widget _buildFooterActions(BuildContext context, ThemeColors tc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: Border.fromBorderSide(BorderSide.none) != BorderSide.none
          ? null
          : BoxDecoration(border: Border(top: BorderSide(color: tc.border))),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                // TODO: Clear chat history dialog
              },
              icon: Icon(Icons.delete_outline_rounded, color: tc.red, size: 18),
              label: Text('Clear All', style: TextStyle(color: tc.red, fontSize: 13, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // TODO: Export conversations action
            },
            icon: Icon(Icons.ios_share_rounded, color: tc.text70, size: 18),
            label: Text('Export', style: TextStyle(color: tc.text70, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Chat group wrapper ────────────────────────────────────────────────────────
class _ChatGroup extends StatelessWidget {
  const _ChatGroup({required this.items, required this.tc});
  final List<Widget> items;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Text('No recent conversations', style: TextStyle(color: tc.text40, fontSize: 13)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(children: [
            e.value,
            if (!isLast) Divider(height: 1, color: tc.border, indent: 52),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── Custom Chat List Item ────────────────────────────────────────────────────
class _ChatItem extends StatelessWidget {
  const _ChatItem({
    required this.title,
    required this.time,
    required this.isSelected,
    required this.tc,
    this.onTap,
  });
  final String title;
  final String time;
  final bool isSelected;
  final ThemeColors tc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? tc.limeDim.withValues(alpha: 0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(
            isSelected ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
            color: isSelected ? tc.lime : tc.text70,
            size: 18
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: tc.text100,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(time, style: TextStyle(color: tc.text40, fontSize: 11)),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: tc.text20, size: 18),
      ]),
    ),
  );
}