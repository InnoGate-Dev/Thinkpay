import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/chat_message_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

import '../../component/navbar.dart';
import 'chathistory.dart';

// ── Mock AI responses ─────────────────────────────────────────────────────────
const _aiResponses = {
  'budget':  'Budgeting is the foundation of financial health! Try the 50/30/20 rule: 50% for needs, 30% for wants, and 20% for savings. Your current spending patterns can guide you to create realistic budget targets. 💡',
  'save':    'Great mindset! A solid savings strategy: start with an emergency fund covering 3–6 months of expenses, then focus on long-term goals. Even saving 10% of your income consistently makes a big difference over time. 📈',
  'invest':  'Before investing, ensure you have zero high-interest debt and a stable emergency fund. Then explore index funds for passive growth, or mutual funds for managed returns. Diversification is key! 🚀',
  'debt':    'To tackle debt effectively, use the Avalanche Method — pay minimums on all debts, but put extra money toward the highest-interest debt first. This saves you the most money long-term. 💪',
  'expense': 'Tracking expenses is the first step to financial freedom! Review your spending weekly, look for subscriptions you no longer use, and categorize everything to spot where your money is going. 🔍',
  'income':  'Growing your income is just as important as cutting expenses. Consider upskilling, freelancing, or passive income streams like investments or a side business. Multiple income sources reduce financial risk! 💼',
  'goal':    'Setting SMART financial goals (Specific, Measurable, Achievable, Relevant, Time-bound) is crucial. Write your goals down and break them into monthly milestones to stay on track. 🎯',
  'credit':  'A good credit score opens doors to better loan rates. Pay bills on time, keep credit utilization below 30%, and avoid opening too many new accounts at once. Monitor your credit report annually. 💳',
  'tax':     'Smart tax planning can save you significantly. Maximize tax-advantaged accounts, claim all eligible deductions, and keep receipts for business expenses. Consider consulting a CA for personalized advice. 📋',
};

String _generateResponse(String input) {
  final lower = input.toLowerCase();
  for (final entry in _aiResponses.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  final generic = [
    'Great question! Financial wellness is a journey. Start by tracking your income and expenses, set clear goals, and review your budget monthly. I\'m here to help you every step of the way! 😊',
    'That\'s something worth thinking about carefully. The key principles are: spend less than you earn, save consistently, and invest for the future. What specific area would you like to explore?',
    'Building financial discipline takes time, but the rewards are worth it. Would you like tips on budgeting, saving, investing, or managing debt? Let me know where you\'d like to focus!',
  ];
  return generic[Random().nextInt(generic.length)];
}

// ── Widget ────────────────────────────────────────────────────────────────────
class Aichat extends StatefulWidget {
  const Aichat({super.key});
  @override
  State<Aichat> createState() => _AichatState();
}

class _AichatState extends State<Aichat> {
  final _provider   = FinanceProvider();
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode  = FocusNode();
  bool _isTyping    = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    _focusNode.requestFocus(); // keep keyboard open

    _provider.addMessage(ChatMessage(
      id: _provider.newId().toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    setState(() => _isTyping = true);
    _scrollToBottom();

    await Future.delayed(
        Duration(milliseconds: 800 + Random().nextInt(1200)));

    if (!mounted) return;
    _provider.addMessage(ChatMessage(
      id: _provider.newId().toString(),
      content: _generateResponse(text),
      isUser: false,
      timestamp: DateTime.now(),
    ));
    if (mounted) setState(() => _isTyping = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final messages = _provider.messages;

        return Scaffold(
          backgroundColor: tc.background,
          onDrawerChanged: (isOpen) => drawerOpenNotifier.value = isOpen,
          // Let Scaffold push content up when keyboard appears
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: Builder(builder: (context){
              return IconButton(onPressed: (){
                Scaffold.of(context).openDrawer();
              }, icon: Icon(Icons.menu),);
            }),
            backgroundColor: tc.surface,
            elevation: 0,
            titleSpacing: 16,
            title: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tc.limeDim,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tc.limeBorder),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: tc.lime, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Financial Adviser',
                        style: TextStyle(
                            color: tc.text100,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text(
                      _isTyping ? 'Typing…' : 'Online',
                      style: TextStyle(
                          color: _isTyping ? tc.lime : tc.text40,
                          fontSize: 11),
                    ),
                  ]),
            ]),
          ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
              child: ChathistoryDrawer()
          ),
          body: Column(
            children: [
              // ── Messages list ──────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (_isTyping && i == messages.length) {
                      return _TypingIndicator(tc: tc);
                    }
                    return _MessageBubble(message: messages[i], tc: tc);
                  },
                ),
              ),

              // ── Input bar ─────────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  16, 12, 16,
                  12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: tc.surface,
                  border: Border(top: BorderSide(color: tc.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(children: [
                    // Text input
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 46),
                        decoration: BoxDecoration(
                          color: tc.surface2,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: tc.border),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: TextField(
                          controller: _inputCtrl,
                          focusNode: _focusNode,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          style: TextStyle(
                              color: tc.text100, fontSize: 14),
                          decoration: InputDecoration(
                            hintText:
                                'Ask about budgeting, savings, investing…',
                            hintStyle: TextStyle(
                                color: tc.text40, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Send button
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: tc.lime,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.send_rounded,
                            color: tc.background, size: 20),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.tc});
  final ChatMessage message;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: tc.limeDim,
                shape: BoxShape.circle,
                border: Border.all(color: tc.limeBorder),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  color: tc.lime, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? tc.lime.withValues(alpha: 0.15)
                    : tc.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser ? tc.limeBorder : tc.border,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? tc.limeAccent : tc.text100,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.tc});
  final ThemeColors tc;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900))
      ..repeat();
    _anim = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: tc.limeDim,
            shape: BoxShape.circle,
            border: Border.all(color: tc.limeBorder),
          ),
          child:
              Icon(Icons.auto_awesome_rounded, color: tc.lime, size: 14),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: tc.border),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context2, child2) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase =
                    (_anim.value - i * 0.2).clamp(0.0, 1.0);
                final opacity = (sin(phase * pi)).clamp(0.3, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tc.lime.withValues(alpha: opacity),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }
}
