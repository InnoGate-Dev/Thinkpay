import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/news_model.dart';
import 'package:Thinkpay/ui/component/news_card.dart';
import 'package:Thinkpay/ui/component/news_category_chip.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String selectedCategory = 'All';

  final List<NewsModel> newsItems = [
    NewsModel(
      title: 'The shift towards sustainable index funds accelerates',
      category: 'Investing',
      whyItMatters: 'A reallocation in major indices might slightly adjust the long-term yield projections of your current passive portfolio. No immediate action required, but good for situational awareness.',
      imageUrl: 'https://images.unsplash.com/photo-1611974714851-eb6046182246?q=80&w=2070&auto=format&fit=crop',
      sourceName: 'Financial Times',
      sourceIconUrl: 'https://www.ft.com/__origami/service/image/v2/images/raw/ftlogo-v1%3Abrand-ft-logo-square?source=next&format=png&width=180',
      timeAgo: '2h ago',
      content: 'Sustainable investing has moved from a niche interest to a mainstream powerhouse. New data shows that major index funds are increasingly tilting towards companies with high ESG (Environmental, Social, and Governance) scores. This shift is not just about ethics; it\'s about long-term risk management and performance stability in an evolving global economy.',
    ),
    NewsModel(
      title: 'Interest rates hold steady amidst cooling inflation data',
      category: 'Economy',
      whyItMatters: 'Your high-yield savings account rates are likely to remain stable for the next quarter. This provides a clear runway for your emergency fund growth strategy without unexpected dips.',
      imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?q=80&w=2070&auto=format&fit=crop',
      sourceName: 'DayOne Research',
      sourceIconUrl: 'https://ui-avatars.com/api/?name=DR&background=0D8ABC&color=fff',
      timeAgo: '5h ago',
      content: 'The Federal Reserve announced today that it will maintain current interest rates, citing a positive trend in cooling inflation. Economists suggest this stability is a "wait and see" approach as they monitor job market data and consumer spending habits into the next quarter.',
    ),
    NewsModel(
      title: 'Understanding the new urban housing metrics',
      category: 'Real Estate',
      whyItMatters: 'If you are saving for a down payment, the stabilization in urban core pricing suggests less pressure to rush. Focus on consistent saving over timing the market.',
      imageUrl: 'https://images.unsplash.com/photo-1448630360428-65ff2ede00a2?q=80&w=2070&auto=format&fit=crop',
      sourceName: 'WSJ Markets',
      sourceIconUrl: 'https://images.crunchbase.com/image/upload/c_lpad,h_170,w_170,f_auto,b_white,q_auto:eco,dpr_1/v1453912642/rqux6ix8nd9k2c7m0y6v.png',
      timeAgo: '1d ago',
      content: 'New metrics for urban housing are revealing a shift in demand away from city centers towards well-connected suburbs. This "doughnut effect" is reshaping property values and rental markets across major metropolitan areas.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'News',
          style: AppTypography.headlineLgMobile.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage('https://ui-avatars.com/api/?name=User'),
              backgroundColor: colors.surface2,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector
          
          // News List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final news = newsItems[index];
                if (selectedCategory != 'All' && news.category != selectedCategory) {
                  return const SizedBox.shrink();
                }
                return NewsCard(
                  news: news,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/news-details",
                      arguments: news,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
