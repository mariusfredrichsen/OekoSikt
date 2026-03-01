import 'package:flutter/material.dart';
import 'package:frontend/core/models/navigation_item.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/services/transaction_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/history/pages/history_page.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/features/spending/pages/spending_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  NavigationItem _currentItem = NavigationItem.home;
  List<Transaction> _allTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await TransactionService.loadTransactions();
      setState(() {
        _allTransactions = data;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingView();
    if (_errorMessage != null) return _buildErrorView();
    if (_allTransactions.isEmpty) return _buildIsEmptyView();

    return Scaffold(
      body: IndexedStack(
        index: _currentItem.index,
        children: [
          const HomePage(),
          HistoryPage(transactions: _allTransactions),
          SpendingPage(transactions: _allTransactions),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentItem.index,
        onTap: (index) {
          setState(() {
            _currentItem = NavigationItem.values[index];
          });
        },
        selectedItemColor: AppColors.navy,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: NavigationItem.values.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildErrorView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIsEmptyView() {
    return const Scaffold(body: Center(child: Text('No transactions found')));
  }
}
