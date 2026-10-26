import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/features/copilot/application/copilot_hands_free.dart';
import 'package:kgwebo/features/copilot/domain/copilot_turn.dart';

void main() {
  test('asks before opening a sale form', () {
    expect(
      CopilotHandsFree.offerFor('I want to record a sale'),
      CopilotOffer.recordSale,
    );
    expect(CopilotHandsFree.wantsOpenForm('I want to record a sale'), isFalse);
  });

  test('open it means the form, help me stays on Ask', () {
    expect(CopilotHandsFree.wantsOpenForm('open it'), isTrue);
    expect(CopilotHandsFree.wantsOpenForm('open the modal'), isTrue);
    expect(CopilotHandsFree.wantsHelpHere('help me'), isTrue);
    expect(CopilotHandsFree.wantsHelpHere('open the page'), isFalse);
  });

  test('does not treat a sold sentence as an empty record request', () {
    expect(
      CopilotHandsFree.offerFor('I sold two shirts for P300'),
      CopilotOffer.none,
    );
  });

  test('help copy uses the profile currency name', () {
    expect(
      CopilotHandsFree.helpPrompt(
        CopilotOffer.recordExpense,
        currencyCode: 'ZAR',
      ).toLowerCase(),
      contains('rand'),
    );
    expect(
      CopilotHandsFree.helpPrompt(
        CopilotOffer.recordExpense,
        currencyCode: 'ZAR',
      ).toLowerCase(),
      isNot(contains('pula')),
    );
    expect(
      CopilotHandsFree.helpPrompt(
        CopilotOffer.recordSale,
        currencyCode: 'USD',
      ).toLowerCase(),
      contains('us dollars'),
    );
  });
}
