import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_container.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: '欢迎使用今天吃点啥',
      description: '帮助您更好地管理冰箱中的食材，避免浪费',
      icon: Icons.kitchen,
    ),
    OnboardingItem(
      title: '添加食材',
      description: '记录食材的名称、数量、购买日期和过期时间',
      icon: Icons.add_circle,
    ),
    OnboardingItem(
      title: '分类管理',
      description: '按照不同类别整理食材，一目了然',
      icon: Icons.category,
    ),
    OnboardingItem(
      title: '过期提醒',
      description: '及时提醒您食材的保质期，避免过期',
      icon: Icons.notifications,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 40),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              _items.length,
              (index) => Container(
                margin: EdgeInsets.only(right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
          _currentPage == _items.length - 1
              ? ElevatedButton(
                  onPressed: _finishOnboarding,
                  child: Text('开始使用'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text('下一步'),
                ),
        ],
      ),
    );
  }

  void _finishOnboarding() async {
    // 记录已经显示过引导页
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_shown_onboarding', true);

    // 跳转到主页面
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainContainer()),
      );
    }
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
} 