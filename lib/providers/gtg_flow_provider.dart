import 'package:flutter/foundation.dart';

/// Holds user selections across the "Let's Good To Go" multi-step flow.
class GtgFlowProvider extends ChangeNotifier {
  int _currentStep = 0;
  int _numberOfFriends = 2;
  int _budgetPerPerson = 500;
  final Set<String> _selectedModes = {};
  int _hoursToSpend = 4;
  double _rangeKm = 1.0;

  int get currentStep => _currentStep;
  int get numberOfFriends => _numberOfFriends;
  int get budgetPerPerson => _budgetPerPerson;
  Set<String> get selectedModes => _selectedModes;
  int get hoursToSpend => _hoursToSpend;
  double get rangeKm => _rangeKm;

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setNumberOfFriends(int n) {
    _numberOfFriends = n;
    notifyListeners();
  }

  void setBudget(int amount) {
    _budgetPerPerson = amount;
    notifyListeners();
  }

  void toggleMode(String mode) {
    if (_selectedModes.contains(mode)) {
      _selectedModes.remove(mode);
    } else {
      _selectedModes.add(mode);
    }
    notifyListeners();
  }

  void setHours(int h) {
    _hoursToSpend = h;
    notifyListeners();
  }

  void setRange(double km) {
    _rangeKm = km;
    notifyListeners();
  }

  void reset() {
    _currentStep = 0;
    _numberOfFriends = 2;
    _budgetPerPerson = 500;
    _selectedModes.clear();
    _hoursToSpend = 4;
    _rangeKm = 1.0;
    notifyListeners();
  }
}
