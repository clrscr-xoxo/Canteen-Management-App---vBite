import 'package:flutter/foundation.dart';
import '../../core/services/admin_reports_service.dart';

class AdminReportsProvider with ChangeNotifier {
  // Current time range
  ReportTimeRange _selectedTimeRange = ReportTimeRange.today;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Loading states
  bool _isLoading = false;
  String? _errorMessage;

  // Revenue data
  Map<String, dynamic>? _revenueData;

  // Top selling items
  List<Map<String, dynamic>> _topSellingItems = [];

  // Order statistics
  Map<String, dynamic>? _orderStatistics;

  // Peak hours data
  Map<String, dynamic>? _peakHoursData;

  // Getters
  ReportTimeRange get selectedTimeRange => _selectedTimeRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  Map<String, dynamic>? get revenueData => _revenueData;
  List<Map<String, dynamic>> get topSellingItems => _topSellingItems;
  Map<String, dynamic>? get orderStatistics => _orderStatistics;
  Map<String, dynamic>? get peakHoursData => _peakHoursData;

  // Set time range
  void setTimeRange(ReportTimeRange range, {DateTime? customStart, DateTime? customEnd}) {
    _selectedTimeRange = range;
    _customStartDate = customStart;
    _customEndDate = customEnd;
    notifyListeners();
  }

  // Load all reports data
  Future<void> loadReportsData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        loadRevenueData(),
        loadTopSellingItems(),
        loadOrderStatistics(),
        loadPeakHoursAnalysis(),
      ]);
    } catch (e) {
      _errorMessage = 'Error loading reports: $e';
      debugPrint('Error loading reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load revenue data
  Future<void> loadRevenueData() async {
    try {
      _revenueData = await AdminReportsService.getRevenueData(
        _selectedTimeRange,
        customStart: _customStartDate,
        customEnd: _customEndDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading revenue data: $e');
      _errorMessage = 'Error loading revenue data: $e';
      notifyListeners();
    }
  }

  // Load top selling items
  Future<void> loadTopSellingItems() async {
    try {
      _topSellingItems = await AdminReportsService.getTopSellingItems(
        _selectedTimeRange,
        customStart: _customStartDate,
        customEnd: _customEndDate,
        limit: 10,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading top selling items: $e');
      _errorMessage = 'Error loading top selling items: $e';
      notifyListeners();
    }
  }

  // Load order statistics
  Future<void> loadOrderStatistics() async {
    try {
      _orderStatistics = await AdminReportsService.getOrderStatistics(
        _selectedTimeRange,
        customStart: _customStartDate,
        customEnd: _customEndDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading order statistics: $e');
      _errorMessage = 'Error loading order statistics: $e';
      notifyListeners();
    }
  }

  // Load peak hours analysis
  Future<void> loadPeakHoursAnalysis() async {
    try {
      _peakHoursData = await AdminReportsService.getPeakHoursAnalysis(
        _selectedTimeRange,
        customStart: _customStartDate,
        customEnd: _customEndDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading peak hours analysis: $e');
      _errorMessage = 'Error loading peak hours analysis: $e';
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadReportsData();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}








