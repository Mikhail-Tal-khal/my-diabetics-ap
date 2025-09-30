class TestResult {
  final DateTime date;
  final double bloodSugar;
  final String status;

  TestResult({
    required this.date,
    required this.bloodSugar,
    required this.status,
  });

  get sugarLevel => null;

  bool? get isNormal => null;

  DateTime? get timestamp => null;
}
