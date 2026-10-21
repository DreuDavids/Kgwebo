/// Thrown when financial arithmetic cannot be completed correctly.
class FinanceException implements Exception {
  const FinanceException(this.message);

  final String message;

  @override
  String toString() => message;
}
