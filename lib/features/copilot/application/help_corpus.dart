class HelpArticle {
  const HelpArticle({
    required this.title,
    required this.body,
    required this.keywords,
  });

  final String title;
  final String body;
  final List<String> keywords;
}

abstract final class KgweboHelpCorpus {
  static const articles = <HelpArticle>[
    HelpArticle(
      title: 'Record a sale',
      keywords: ['sale', 'sold', 'income', 'record sale'],
      body:
          'Open Ask or Money and record a sale. Enter the amount in your business currency, pick a category, set the date, and say whether the customer has already paid. Kgwebo does not save the sale until you confirm. Opening cash is not a sale.',
    ),
    HelpArticle(
      title: 'Record an expense',
      keywords: ['expense', 'spent', 'cost', 'record expense', 'bought'],
      body:
          'Describe the cost here or open Record an expense. Enter the operating cost in your business currency, pick a category such as transport or fees, and mark it paid only if cash has already left. Owner withdrawals are not operating expenses.',
    ),
    HelpArticle(
      title: 'Opening cash',
      keywords: ['opening', 'starting cash', 'opening balance'],
      body:
          'Opening cash is the money the business already had. It is a starting position, not revenue and not a sale. You set it in the business profile.',
    ),
    HelpArticle(
      title: 'Pending sync',
      keywords: ['offline', 'pending', 'sync', 'queue'],
      body:
          'If a simple sale or unpaid bill cannot be saved, Kgwebo can keep it as a pending change. Pending items are not counted as cash. Product sales and stock changes need an internet connection.',
    ),
    HelpArticle(
      title: 'Products and stock',
      keywords: ['product', 'stock', 'inventory', 'catalogue'],
      body:
          'Add products from the Stock tab. Stock is a ledger. A product sale decreases stock once. Kgwebo rejects overselling. Estimated inventory value is not cash.',
    ),
    HelpArticle(
      title: 'Recommendations',
      keywords: ['recommendation', 'warning', 'advice', 'forecast'],
      body:
          'Cash-flow recommendations come from recorded bills, stock and totals. They are not professional financial advice. You can dismiss a recommendation when you have reviewed it.',
    ),
    HelpArticle(
      title: 'Ask Kgwebo',
      keywords: ['ai', 'assistant', 'suggest', 'automatic', 'ask'],
      body:
          'Ask can explain recorded figures, show charts, and suggest draft sales or expenses from your words. It never saves them until you review and confirm. Suggestions can be wrong. Ordinary screens always work if Ask is offline.',
    ),
  ];

  static HelpArticle? match(String question) {
    final haystack = question.trim().toLowerCase();
    if (haystack.isEmpty) {
      return null;
    }
    HelpArticle? best;
    var bestScore = 0;
    for (final article in articles) {
      var score = 0;
      for (final keyword in article.keywords) {
        if (haystack.contains(keyword)) {
          score += keyword.split(' ').length;
        }
      }
      if (score > bestScore) {
        best = article;
        bestScore = score;
      }
    }
    return best;
  }
}
