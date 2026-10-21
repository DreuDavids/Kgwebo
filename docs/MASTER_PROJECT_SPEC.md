# KGWEBO

## Master Product, Design, Architecture and Development Specification

**Project:** Kgwebo — Intelligent Business Management and Financial Guidance  
**Competition:** FNB App of the Year 2026 Hackathon  
**Challenge:** Youth Entrepreneurship and Small-Business Growth  
**Platform:** Android mobile application  
**Required framework:** Flutter and Dart  
**Backend:** Supabase and PostgreSQL  
**Initial market:** Botswana, with an architecture suitable for expansion across Africa  
**Currency:** Botswana pula (BWP), configurable for future markets  
**Primary objective:** Build a complete, polished, reliable and demonstrable application that solves a genuine problem for small-business owners.

---

# PART 1 — MASTER INSTRUCTIONS TO CURSOR

## 1. Your Role

Act as a senior Flutter engineer, software architect, product designer, financial-systems engineer, quality-assurance engineer and mobile accessibility specialist.

Your responsibility is to design, implement, test and deliver Kgwebo as a working application, not merely generate code snippets, mockups or a development plan.

Work directly in the existing repository.

Before changing code:

1. Inspect the entire project structure and existing implementation.
2. Identify the current Flutter and Dart versions, dependencies, architecture, Android configuration, existing assets and tests.
3. Identify reusable code and existing defects.
4. Create a detailed implementation plan based on the actual repository.
5. Identify any external setup requirements, such as Supabase credentials.
6. Start implementing the project in logical, testable stages.

Do not replace working functionality without a good reason. Do not create a second competing architecture when the repository already has a sound one.

If the repository is empty, initialise a clean Flutter project using a maintainable architecture.

### Mandatory development rules

- Flutter and Dart must be used for the application.
- The application must run on Android devices with different screen sizes, resolutions, pixel densities and orientations.
- Do not hardcode layouts for a single phone or screen size.
- Do not use fixed-height page layouts that overflow on small screens.
- Do not leave buttons, forms, menus or navigation elements non-functional.
- Do not use fake financial calculations or hardcoded dashboard totals in production functionality.
- Do not mark a feature complete until its acceptance tests pass.
- Do not hide errors, swallow exceptions or report success when an operation fails.
- Do not commit API secrets or service-role keys to the application.
- Do not use a successful build as proof that the application works correctly.
- Use realistic demo data only in an explicitly identified demo or seeded environment.
- Do not wait for optional integrations before implementing independent functionality.
- If a requirement is ambiguous, choose the safest practical implementation, document the assumption and continue.
- If an external service is unavailable, build and test the parts that do not depend on it. Clearly document the remaining setup.
- Never claim that tests passed unless they were actually executed and their results inspected.

The final result should look like a professionally designed commercial fintech product, not a generic Flutter template.

---

# PART 2 — PRODUCT DEFINITION

## 2. The Problem

Many small-business owners and informal traders maintain incomplete records of sales, expenses, supplier payments and inventory.

They may receive money regularly without knowing:

- How much revenue they have generated.
- How much they have spent operating the business.
- Whether the business is making a profit.
- How much cash is available after known obligations.
- Whether they can afford to restock products.
- Whether they are approaching a cash shortage.
- How to present a clear record of their business performance.

Kgwebo should make this information understandable and actionable without requiring accounting expertise.

## 3. Product Vision

Kgwebo is a mobile-first business companion that helps entrepreneurs record business activity, understand their financial position and make better decisions about their next steps.

Its central promise is:

**Your business. Clearer decisions. Stronger growth.**

The product must move beyond displaying historical numbers. It should help users understand what those numbers mean and what they may need to do next.

## 4. Target User

The initial target user is an informal trader or small retail business owner in Botswana.

Examples include:

- Clothing and accessory sellers.
- Small grocery shops.
- Market traders.
- Small household-goods retailers.
- Entrepreneurs selling products through WhatsApp or social media.

Design for people who may have limited accounting knowledge, limited time, unreliable connectivity and affordable Android devices.

Do not assume that users have bank integrations, card terminals, formal accounting systems or reliable internet access.

## 5. Core User Journey

A new user must be able to:

1. Open Kgwebo and understand its value.
2. Create an account or explore an explicitly labelled demo.
3. Set up their business profile.
4. Record their opening cash balance.
5. Add products and their costs and selling prices.
6. Record a sale.
7. Record an expense or upcoming obligation.
8. View updated financial summaries.
9. Understand an identified cash-flow risk.
10. Review a recommendation and its supporting figures.
11. Generate a business report.
12. Return later and find their data intact.

The complete journey must work end to end.

---

# PART 3 — VISUAL DESIGN AND USER EXPERIENCE

## 6. Design Direction

Create a premium, modern, approachable financial-product experience.

The visual identity should feel trustworthy, energetic and polished. Avoid generic admin-dashboard styling, excessive gradients, excessive rounded cards, overcrowded screens and default-looking Flutter components.

Use a consistent design system across every screen.

### Brand direction

- Product name: Kgwebo.
- Tagline: Your business. Clearer decisions. Stronger growth.
- Visual personality: intelligent, dependable, contemporary, African-market aware and accessible.
- Primary theme: light mode.
- Typography: a highly legible modern typeface, using a consistent type scale.
- Icons: a consistent icon family with clear meaning.
- Currency formatting: Botswana pula, displayed consistently as BWP or P, with two decimal places where appropriate.
- Date and number formatting: locale-aware, with sensible defaults for Botswana.
- Language: English for the initial release, with architecture that can support Setswana and additional languages later.

Do not use national flags, cultural motifs or decorative imagery merely for decoration. The design should be relevant to the audience without compromising clarity.

### Proposed visual tokens

Treat these as initial design tokens, not arbitrary values scattered through widgets.

- Primary: deep forest green.
- Secondary: teal.
- Accent: warm amber for selected highlights.
- Background: warm off-white.
- Surface: white.
- Primary text: dark charcoal.
- Secondary text: muted slate.
- Success: accessible green.
- Warning: amber with sufficient contrast.
- Error: accessible red.
- Borders: subtle neutral grey.

Create a central theme and token system. Every screen must reuse it.

Use color, icons and text together to communicate status. Never use color alone.

### Layout principles

- Use generous but efficient spacing.
- Establish a clear hierarchy between the page title, primary action, key information and secondary content.
- Use strong typography and consistent alignment.
- Present financial information in a way that makes the important numbers easy to scan.
- Avoid showing every possible metric at once.
- Use subtle borders, restrained elevation and consistent corner radii.
- Use charts only when they help the user understand their business.
- Use appropriate empty states with clear calls to action.
- Provide useful loading, success, error and offline states.
- Use animations sparingly and only where they improve comprehension.
- Respect Android system navigation, status bars, insets and display cutouts.

### Required design-system components

Create reusable components for:

- Primary and secondary buttons.
- Icon buttons with accessible labels.
- Text fields and numeric fields.
- Currency input fields.
- Date pickers.
- Search fields.
- Filter chips.
- Status indicators.
- Summary cards.
- Transaction list items.
- Product list items.
- Chart containers.
- Empty states.
- Loading skeletons or progress indicators.
- Error messages and retry actions.
- Confirmation dialogs.
- Bottom sheets.
- Snackbars or equivalent feedback.
- Section headings.
- Responsive navigation.
- Accessible form validation messages.

Do not independently style the same component differently on every screen.

## 7. Mandatory Android Responsiveness

This is a release requirement, not an optional enhancement.

The application must adapt to:

- Small Android phones.
- Standard Android phones.
- Large phones.
- Foldable devices where supported by Flutter's normal layout mechanisms.
- Android tablets.
- Portrait orientation.
- Landscape orientation.
- Different font scales.
- Display cutouts and system insets.
- Devices using gesture or three-button navigation.
- Narrow widths and large text settings.

### Implementation requirements

1. Use `LayoutBuilder`, `MediaQuery` and flexible constraints where appropriate.
2. Prefer `Expanded`, `Flexible`, `Wrap`, scrollable content and adaptive layouts over fixed dimensions.
3. Use breakpoints based on available logical width, not device model names.
4. Use a compact navigation pattern on narrow layouts and a wider navigation rail or suitable tablet layout when there is sufficient space.
5. Keep primary actions reachable and visible.
6. Allow forms, dialogs and bottom sheets to scroll when keyboard space is limited.
7. Ensure numeric fields and currency amounts do not overflow.
8. Avoid placing all dashboard cards in a single rigid row.
9. Support orientation changes without losing unsaved user input.
10. Preserve navigation and screen state appropriately during resizing and orientation changes.
11. Prevent charts, tables, text and buttons from clipping.
12. Use `SafeArea` or equivalent inset-aware layout patterns.
13. Do not disable orientation changes just to avoid implementing responsive layouts.

Use a consistent responsive grid. For example, the dashboard may use a single-column layout on narrow phones, two columns when space permits and a more expansive layout on tablets.

Do not treat any particular example width as a universal device category. Measure the actual available space.

### Text scaling and accessibility

- Support Android font scaling without clipped text.
- Give interactive elements clear semantic labels.
- Use sensible touch targets, aiming for approximately 48 logical pixels for common interactive controls.
- Ensure keyboard navigation and screen-reader semantics are appropriate.
- Maintain sufficient color contrast.
- Do not communicate essential information exclusively through charts.
- Respect reduced-motion preferences where applicable.

---

# PART 4 — APPLICATION ARCHITECTURE

## 8. Required Technology Stack

Use compatible stable versions of dependencies, selecting versions that work with the installed Flutter and Dart SDK.

### Frontend

- Flutter.
- Dart.
- Material 3 with a customised design system.
- Riverpod for state management and dependency injection.
- GoRouter for navigation and route guards.
- `fl_chart` for charts where appropriate.
- A maintained form-validation solution or well-structured native validation.
- `intl` for currency, date and number formatting.

### Backend

- Supabase Auth.
- PostgreSQL through Supabase.
- Supabase Row Level Security.
- Supabase Edge Functions only when server-side execution is needed.
- Supabase Storage only if future features require document storage.

### Local persistence

- Drift with SQLite for structured offline transaction storage, if its implementation is compatible with the project.
- A persistent synchronisation queue for offline operations.
- Secure local storage for sensitive tokens or secrets when needed.

Never store authentication secrets in ordinary preferences.

### Testing

- Flutter unit tests.
- Flutter widget tests.
- Flutter integration tests.
- Repository and database-policy tests.
- Static analysis using `flutter analyze`.
- Formatting checks using `dart format`.
- Android release-build verification.

Use additional libraries only when they solve a concrete need. Do not add dependencies simply because they are popular.

## 9. Architecture Requirements

Use a maintainable feature-oriented architecture.

Suggested structure:

```text
lib/
  app/
    app.dart
    router.dart
    theme/
    config/
  core/
    errors/
    formatting/
    validation/
    responsive/
    security/
    networking/
    sync/
  features/
    onboarding/
    authentication/
    business_profile/
    dashboard/
    transactions/
    products/
    cash_flow/
    recommendations/
    reports/
    settings/
  shared/
    widgets/
    models/
```

Each feature should separate, where appropriate:

- Presentation and UI.
- State management.
- Domain models and business rules.
- Repository interfaces.
- Data sources and repository implementations.
- Tests.

Do not create unnecessary abstraction layers for simple operations, but ensure financial logic can be tested independently of the UI.

The widget tree must not contain financial calculations, database queries or large blocks of business logic.

## 10. Environment Configuration

Provide a documented `.env.example` or equivalent configuration template containing non-secret configuration placeholders.

Example:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
APP_ENV=development
```

Use only the current, appropriate public client key for the installed Supabase configuration. Never embed a Supabase service-role key or other privileged credential in the Flutter application.

The app must handle missing backend configuration gracefully in development and testing.

Do not silently substitute demo data for production data.

Clearly distinguish:

- Live backend mode.
- Local/offline mode.
- Explicit demo mode.

---

# PART 5 — FEATURES AND EXPECTED BEHAVIOUR

## 11. Feature A: Onboarding

### Purpose

Explain the value of Kgwebo quickly and guide the user into the application.

### Required screens

1. Welcome screen.
2. Short explanation of business tracking.
3. Short explanation of cash-flow insights.
4. Account creation or sign-in.
5. Business setup.

Do not make onboarding unnecessarily long.

### Behaviour

- Users can move forward and backward where appropriate.
- Users can skip non-essential educational screens.
- Onboarding must not claim to have saved business data before it is saved.
- Returning users should not be forced to repeat completed onboarding unnecessarily.
- A user who closes the app should not lose an already saved business profile.
- Provide an accessible way to sign in to an existing account.

### Acceptance tests

- First launch displays onboarding.
- Completing onboarding reaches the intended next screen.
- Returning users can resume their session.
- Navigation does not create duplicate business profiles.
- Orientation changes do not reset entered information.
- Small screens do not clip the main call to action.

## 12. Feature B: Authentication

### Required functionality

- Email and password registration.
- Login.
- Logout.
- Session persistence.
- Password reset.
- Validation and understandable error messages.
- Appropriate loading states.
- Session expiry handling.

If email confirmation is enabled in Supabase, implement the confirmation flow and tell the user what to do next.

### Behaviour

- Invalid credentials must not create a false success state.
- Duplicate accounts must be handled gracefully.
- Network errors must provide retry options.
- Protected screens must not expose another user's business data.
- Logout must clear the active authenticated session.
- Password reset must use a secure Supabase-supported flow.
- Never log passwords or access tokens.

### Acceptance tests

Test valid and invalid registration, login, logout, session restoration, password reset and expired sessions.

Verify that an unauthenticated user cannot access protected business records.

## 13. Feature C: Business Profile and Setup

Each user should be able to create and manage a business profile.

### Fields

- Business name.
- Business type.
- Country.
- Currency.
- Optional description.
- Business start date.
- Opening cash balance.
- Optional contact details.

Initially, default the country to Botswana and currency to BWP. Do not permanently hardcode the financial system to Botswana, because future expansion should be possible.

### Behaviour

- Validate required fields.
- Allow profile edits.
- Persist the profile.
- Do not permit accidental creation of duplicate profiles during retries.
- Explain what the opening cash balance means.
- Treat the opening balance as a starting position, not revenue.
- Permit an initial zero balance.
- Keep historical financial records when a profile is edited.

### Acceptance tests

Create a profile, restart the app, reopen the profile, edit it and verify persistence.

Confirm that the opening balance does not inflate sales or profit.

## 14. Feature D: Dashboard

The dashboard is the application's main screen and must receive particular design attention.

### Required information

Display:

- Current cash position.
- Sales for a selectable period.
- Expenses for the same period.
- Estimated profit for that period.
- Recent transactions.
- Cash-flow outlook.
- Important recommendations.
- Quick actions.

The dashboard must make it obvious what the user should do next.

### Quick actions

- Record a sale.
- Record an expense.
- Add a product.
- View transactions.
- View cash-flow forecast.
- Generate a report.

### Behaviour

- All displayed figures must derive from the correct underlying records.
- Changing the reporting period must update the relevant metrics and charts.
- Current cash position must not be confused with revenue or profit.
- Loading and empty states must be attractive and informative.
- A user with no transactions should receive a useful setup prompt, not a misleading zero-profit warning.
- Dashboard totals must update after successful transactions.
- Failed saves must not produce false updated totals.
- Refreshing or reopening the app must not lose saved information.

### Acceptance tests

Seed known transactions and independently calculate the expected dashboard values.

Compare the displayed values with the expected results. Test empty data, large values, negative net profit, different date ranges, failed requests and restored sessions.

## 15. Feature E: Sales and Expense Management

This is one of the most important features.

### Transaction types

Support at least:

- Sale.
- Expense.
- Customer refund.
- Owner contribution.
- Owner withdrawal.
- Supplier payment where needed.
- Opening balance adjustment through a controlled adjustment flow.

Do not treat all money inflows as sales or all money outflows as operating expenses.

### Common fields

- Unique transaction identifier.
- Business identifier.
- Transaction type.
- Amount.
- Date and time.
- Category.
- Optional description.
- Optional payment method.
- Optional product association.
- Optional quantity and unit price where applicable.
- Creation and modification timestamps.
- Synchronisation status where needed.

### Recording a sale

Users must be able to:

1. Open the sale form.
2. Enter the sale amount or select products.
3. Enter quantity if products are selected.
4. Review the total.
5. Select a date and payment method if applicable.
6. Save the transaction.
7. See a clear success confirmation.
8. See updated business totals.

Validate positive amounts and sensible quantities. Support fractional quantities only where the selected product allows them.

If a sale contains multiple products, calculate line totals and totals consistently.

### Recording an expense

Users must be able to:

1. Enter an amount.
2. Select an expense category.
3. Enter an optional description.
4. Choose the transaction date.
5. Save and view the result.

Allow users to distinguish paid expenses from upcoming obligations. A planned bill must not reduce current cash before it has actually been paid.

### Editing and deleting

- Provide an edit flow for authorised transactions.
- Require confirmation before deletion.
- Recalculate dependent metrics after edits or deletions.
- Preserve a reliable record of important changes where appropriate.
- Avoid destructive actions that cannot be explained or recovered from.

### Duplicate prevention

Disable repeated submission while saving. Use idempotency or a reliable client-generated operation identifier so retries cannot accidentally duplicate financial transactions.

### Acceptance tests

- Valid sale saves once.
- Invalid amounts are rejected.
- Failed saves preserve user input.
- Repeated taps do not create duplicate transactions.
- Editing a transaction updates totals correctly.
- Deleting a transaction updates totals correctly.
- Refunds are accounted for consistently.
- Owner contributions do not inflate operating revenue.
- Owner withdrawals do not automatically become operating expenses.
- Dates and time zones do not cause transactions to appear in the wrong reporting period.
- Offline entries remain visible and are synchronised safely.

## 16. Feature F: Product and Inventory Management

Inventory is included to support the initial small-retail target market.

### Product fields

- Product identifier.
- Name.
- Optional SKU.
- Purchase or unit cost.
- Selling price.
- Current stock quantity.
- Optional low-stock threshold.
- Unit of measure.
- Active or archived status.
- Creation and modification timestamps.

### Required functionality

- Create products.
- Edit products.
- View product details.
- Search and filter products.
- Record stock movements.
- Identify low-stock products.
- Associate sales with products.
- Calculate line totals.
- Display stock remaining.

### Financial behaviour

For a product sale, record the transaction and stock movement consistently.

Calculate cost of goods sold from the recorded cost basis and quantity sold. Avoid using the current product cost to silently rewrite the historical cost of old sales.

For the MVP, implement a clearly documented cost method, such as the recorded unit cost at the time of sale. If more sophisticated inventory valuation is added later, introduce it deliberately rather than mixing methods.

Prevent selling more stock than is available unless the business has explicitly enabled backorders.

### Acceptance tests

- Product creation and editing persist.
- Stock decreases after a valid product sale.
- Invalid stock movements are rejected.
- Low-stock alerts trigger at the correct threshold.
- Product prices and quantities calculate correctly.
- Historical transactions remain correct after a product's price or cost is edited.
- Failed transactions do not leave stock and financial records inconsistent.

## 17. Feature G: Financial Calculation Engine

Implement financial calculations in a separate, independently tested Dart domain layer.

Use decimal-safe arithmetic for financial values. Prefer integer minor units for monetary amounts or a well-defined decimal representation. Avoid relying on binary floating-point arithmetic for authoritative monetary totals.

Define rounding rules explicitly and apply them consistently.

### Required concepts

**Revenue:** Money earned from sales during the selected period, adjusted according to the documented treatment of refunds.

**Operating expenses:** Business operating costs recognised during the period.

**Cost of goods sold:** The cost associated with products sold during the period, where inventory tracking is enabled.

**Estimated gross profit:** Net sales less cost of goods sold.

**Estimated operating profit:** Gross profit less recognised operating expenses, subject to the accounting scope implemented.

**Current cash position:** Opening cash plus actual cash inflows minus actual cash outflows, adjusted for recorded transactions and the defined treatment of payment methods.

**Upcoming obligations:** Known future payments that have not yet been paid.

**Projected cash position:** Current cash adjusted for expected future inflows and outflows over a defined forecast horizon.

Do not treat a planned obligation as an actual expense and actual cash outflow at the same time.

Document the treatment of credit sales, refunds, owner contributions, owner withdrawals, transfers and unpaid obligations.

If the MVP does not implement accrual accounting, make that limitation clear. Do not present simplified calculations as formal accounting statements.

### Example test data

Starting cash: BWP 2,000.

Cash sale: BWP 500.

Cash operating expense: BWP 100.

Owner contribution: BWP 200.

Owner withdrawal: BWP 50.

Expected cash position: BWP 2,550.

Calculation: 2,000 + 500 − 100 + 200 − 50 = 2,550.

The owner contribution increases cash but is not sales revenue. The owner withdrawal decreases cash but is not automatically an operating expense.

Add separate tests for product cost, refunds, unpaid sales and expenses, and opening balances.

### Financial engine acceptance tests

- Totals match independently calculated expected values.
- Decimal amounts do not accumulate floating-point errors.
- Rounding is consistent.
- Negative profit is represented correctly.
- Opening balances are not counted as revenue.
- Transactions cannot be counted twice.
- Editing and deleting records trigger correct recalculation.
- Date-range calculations use a documented business time zone.
- Forecast figures never overwrite actual transaction figures.
- Unknown or incomplete information is not presented as a verified fact.

## 18. Feature H: Cash-Flow Forecasting

This is a core differentiator for Kgwebo.

### Purpose

Help business owners understand whether recorded cash and expected future activity are sufficient to cover known obligations.

### MVP forecast

Start with an explainable, deterministic forecast based on:

- Current cash position.
- Upcoming bills and their due dates.
- Expected supplier payments.
- Expected customer receipts, if recorded.
- Known scheduled expenses.
- Optional recurring expenses.
- A forecast horizon, such as the next 7, 14 or 30 days.

### Required interface

Show:

- Current cash position.
- Expected inflows.
- Expected outflows.
- Projected cash balance over time.
- Dates on which cash may become insufficient.
- A clear explanation of which transactions affect the forecast.
- A confidence or data-completeness message where appropriate.

A line chart may show the projected cash balance. Also provide a text or table summary so the chart is not the only way to access the information.

### Forecast rules

- Do not count the same obligation twice.
- Distinguish confirmed payments from estimated receipts.
- Do not invent future sales.
- If historical sales are used for estimates, explain the assumption and show that future sales are uncertain.
- Clearly identify forecasts as projections, not guarantees.
- Avoid declaring a cash shortage if the relevant data is incomplete without communicating the limitation.
- Recalculate forecasts when source records change.

### Acceptance tests

Create deterministic test cases with known opening cash, due dates and future inflows and outflows.

Verify projected balances on every relevant date.

Test insufficient cash, zero cash, no upcoming obligations, missing dates, overdue bills, edited obligations and offline changes.

Check that the explanation identifies the correct transactions behind each warning.

## 19. Feature I: Recommendation Engine

Build the initial recommendation engine using deterministic rules.

Do not require an AI API for essential financial recommendations.

### Initial recommendation types

- Potential cash shortfall.
- Upcoming large expense.
- Low inventory.
- Incomplete financial records.
- Unusually high expense compared with the user's recorded baseline.
- Need to review upcoming obligations.
- Opportunity to produce a business performance report.

### Recommendation structure

Each recommendation should contain:

- Title.
- Clear explanation.
- Relevant supporting figures.
- Severity or priority.
- Date created.
- Related transactions or products.
- Suggested action.
- Optional action link.
- Status such as new, viewed, dismissed or resolved.

### Behaviour

Recommendations must be relevant to the user's actual data.

Do not create a warning simply because a user has no transactions. Show a setup or education message instead.

Do not repeatedly display the same unresolved warning on every refresh. Deduplicate similar recommendations using a stable rule and a relevant time window.

Users should be able to review the supporting evidence and dismiss non-critical recommendations.

### Acceptance tests

- Each rule triggers when its defined conditions are met.
- Each rule does not trigger when conditions are not met.
- Recommendations reference the correct records.
- Dismissed recommendations do not reappear immediately without a meaningful new condition.
- Updating source data recalculates recommendation status.
- Users cannot access recommendations belonging to another business.

## 20. Feature J: Conversational Transaction Entry — Optional

This is an optional enhancement, not a dependency for the MVP.

Example user input:

"Sold two shirts for P300 and spent P80 on transport."

The application may use an AI service to convert the description into a proposed structured entry.

### Mandatory safety behaviour

- Display the interpreted transactions before saving.
- Allow the user to edit the amount, category, date and description.
- Never save AI-generated transactions silently.
- Do not treat the AI's interpretation as verified financial data.
- Do not send unnecessary personal or business information to external services.
- Handle service timeouts and malformed responses.
- Provide ordinary manual transaction entry when AI is unavailable.
- Never expose an AI provider secret in the Flutter application.

### Acceptance tests

Test valid descriptions, ambiguous amounts, multiple transactions, unsupported categories, malformed output, service failure and user cancellation.

The feature is complete only when a user can review, edit, confirm and correctly save the interpreted transaction.

If implementation threatens the reliability of core features, omit this enhancement from the first release.

## 21. Feature K: Business Reports

Users should be able to generate a summary of their business activity.

### Report contents

- Business name.
- Reporting period.
- Total sales.
- Refunds, where applicable.
- Expenses.
- Cost of goods sold, where available.
- Estimated profit.
- Opening and closing cash positions where supported.
- Transaction counts.
- Selected product or inventory insights.
- Cash-flow outlook.
- Notes on incomplete data or estimates.

### Requirements

- Provide a readable in-app report preview.
- Support PDF export.
- Use clear headings and consistent number formatting.
- Include the reporting period and currency.
- Avoid misleading charts or totals.
- Ensure long reports paginate correctly.
- Support long business names and large amounts.
- Allow the user to share or save the generated report using supported Android mechanisms.
- Do not expose reports publicly by default.

### Acceptance tests

Compare the report values against the financial engine for a known dataset.

Verify that the exported PDF opens, contains the correct figures, handles multiple pages and does not clip content.

Test an empty business, a business with many transactions and a business with negative profit.

## 22. Feature L: Offline Operation and Synchronisation

The application should remain useful during intermittent connectivity.

### MVP offline scope

Where implemented, users should be able to:

- Open previously cached business data.
- View saved transactions.
- Record new sales and expenses locally.
- See which changes are pending synchronisation.
- Retry synchronisation when connectivity returns.

### Synchronisation design

Use a durable local operation queue with:

- Unique operation identifiers.
- Business and user identifiers.
- Creation timestamps.
- Synchronisation status.
- Retry information.
- Conflict-handling rules.

Do not assume that a connectivity indicator guarantees the backend is reachable.

Prevent duplicate transactions when retries occur.

For financial records, avoid silent last-write-wins behaviour that can overwrite important changes. Use explicit conflict handling where necessary.

Ensure a partially failed synchronisation can resume without duplicating completed operations.

### Acceptance tests

- Record a transaction while offline.
- Force-close and reopen the app.
- Verify the transaction remains available locally.
- Restore connectivity.
- Verify the transaction synchronises once.
- Simulate an API failure during synchronisation.
- Retry and verify no duplicate transaction is created.
- Test conflicting edits and confirm the defined conflict policy is followed.
- Verify another user cannot access locally cached data after logout.

If reliable offline synchronisation cannot be completed within the initial time budget, prioritise robust online transactions and clearly scoped local draft support rather than shipping unsafe financial synchronisation.

## 23. Feature M: Search, Filtering and Transaction History

Provide a searchable transaction history.

### Required filters

- Date range.
- Transaction type.
- Category.
- Amount range, where useful.
- Product, where applicable.

### Behaviour

- Filters can be combined.
- Results display the correct total for the selected dataset.
- Clearing filters restores the full list.
- Empty results provide a useful message.
- Long histories remain performant.
- Pagination or incremental loading is used when appropriate.

### Acceptance tests

Verify exact filter results against known data, combined filters, sorting, empty results and large transaction histories.

## 24. Feature N: Settings and Account Management

Provide settings for:

- Business profile.
- Currency and locale preferences where supported.
- Notification preferences.
- Security and session management.
- Privacy information.
- Data export.
- Sign-out.

Only implement settings that have a defined, working behaviour.

Currency changes must not silently reinterpret existing amounts. If multi-currency support is not fully implemented, lock the business currency after the initial setup or require an explicit migration policy.

---

# PART 6 — DATABASE DESIGN AND SECURITY

## 25. Proposed Data Model

Design and version-control the database schema using Supabase migrations.

Core entities should include:

### `profiles`

- `id` — references the authenticated user.
- `display_name`.
- `created_at`.
- `updated_at`.

### `businesses`

- `id`.
- `owner_id`.
- `name`.
- `business_type`.
- `country_code`.
- `currency_code`.
- `opening_balance_minor`.
- `created_at`.
- `updated_at`.

### `transactions`

- `id`.
- `business_id`.
- `created_by`.
- `idempotency_key`.
- `type`.
- `amount_minor`.
- `currency_code`.
- `category`.
- `description`.
- `occurred_at`.
- `payment_method`.
- `status`.
- `created_at`.
- `updated_at`.

### `products`

- `id`.
- `business_id`.
- `name`.
- `sku`.
- `unit_cost_minor`.
- `selling_price_minor`.
- `stock_quantity`.
- `low_stock_threshold`.
- `unit_of_measure`.
- `is_active`.
- `created_at`.
- `updated_at`.

### `sale_items`

- `id`.
- `transaction_id`.
- `product_id`.
- `quantity`.
- `unit_price_minor`.
- `unit_cost_minor`.
- `line_total_minor`.

### `stock_movements`

- `id`.
- `business_id`.
- `product_id`.
- `transaction_id`, where applicable.
- `movement_type`.
- `quantity_delta`.
- `created_at`.

### `obligations`

- `id`.
- `business_id`.
- `title`.
- `amount_minor`.
- `due_date`.
- `status`.
- `category`.
- `created_at`.
- `updated_at`.

### `recommendations`

- `id`.
- `business_id`.
- `rule_key`.
- `severity`.
- `title`.
- `description`.
- `evidence`.
- `status`.
- `created_at`.
- `updated_at`.

### Additional local-only data

The device may maintain local synchronisation operations, drafts and cached data. These records must not be confused with confirmed server records.

Adapt this schema to the final domain model. Do not create redundant tables or fields without a clear purpose.

Use appropriate foreign keys, indexes, uniqueness constraints, validation and deletion policies.

Store monetary amounts using a defined minor-unit or decimal-safe representation. Document how the chosen representation works for each supported currency.

Use a consistent timestamp policy and business reporting time zone.

## 26. Row Level Security

Enable Row Level Security on every exposed table containing user or business data.

Write policies that verify that the authenticated user is authorised to access the relevant business.

Do not rely only on filtering queries in Flutter.

Test policies against at least two different users, including attempts to:

- Read another user's business.
- Insert a transaction into another user's business.
- Update another user's product.
- Delete another user's obligation.
- Access another user's recommendations.

All such unauthorised requests must fail.

Never expose the Supabase service-role key to the mobile app.

## 27. Data Integrity

Use database transactions or appropriately designed server-side operations when multiple records must change together.

For example, a product sale may require:

1. Creating the sale record.
2. Creating its line items.
3. Recording the stock movement.
4. Updating inventory.
5. Ensuring the financial record is consistent.

A partial failure must not leave the business with a sale but no corresponding stock movement, or stock reduced without a valid sale.

Implement atomic operations where required, with clear retry semantics.

---

# PART 7 — QUALITY ASSURANCE AND TESTING

## 28. Testing Philosophy

Every feature must have documented acceptance criteria and evidence of testing.

Do not write tests merely to increase test counts. Tests must verify actual behaviour.

Use multiple testing layers.

### Unit tests

Test:

- Financial calculations.
- Currency formatting and rounding.
- Validation rules.
- Forecasting logic.
- Recommendation rules.
- Date-range calculations.
- Inventory calculations.
- Synchronisation state transitions.

### Widget tests

Test:

- Forms and validation.
- Loading and error states.
- Empty states.
- Responsive layouts.
- Navigation.
- Transaction confirmation.
- Dashboard updates.
- Accessibility semantics.

### Integration tests

Test complete workflows:

1. Create or sign in to an account.
2. Set up a business.
3. Record a sale.
4. Record an expense.
5. Add a product.
6. Record a product sale.
7. View the updated dashboard.
8. Review a cash-flow warning.
9. Generate a report.
10. Restart the app and verify persistence.

### Backend tests

Test database constraints, authentication, Row Level Security, idempotency, concurrent operations and rollback behaviour.

### Manual Android tests

Test on an emulator and, where possible, at least one physical Android device.

---

# PART 8 — RESPONSIVE AND DEVICE TEST MATRIX

## 29. Required Test Coverage

Create a repeatable test matrix covering representative combinations of size, orientation and text scale.

| Test profile                                              | Orientation            | Required checks                                       |
| --------------------------------------------------------- | ---------------------- | ----------------------------------------------------- |
| Compact phone, approximately 320 logical pixels wide      | Portrait               | No clipped controls, usable forms, scrollable content |
| Standard phone, approximately 360–400 logical pixels wide | Portrait               | Normal dashboard and transaction flows                |
| Large phone                                               | Portrait               | Appropriate spacing without excessive empty space     |
| Standard phone                                            | Landscape              | No overflow; all main actions accessible              |
| Large phone                                               | Landscape              | Adaptive dashboard and charts                         |
| Tablet-sized layout                                       | Portrait               | Appropriate use of available width                    |
| Tablet-sized layout                                       | Landscape              | Multi-column layout where useful                      |
| Any representative device                                 | Large font scale       | No clipped text or inaccessible actions               |
| Device with display cutout                                | Portrait and landscape | Correct system insets                                 |
| Device using gesture navigation                           | Both orientations      | Controls do not conflict with system navigation       |

These are representative profiles, not a claim that every physical Android device has been tested.

### Automated responsive tests

Create widget tests that render key screens at multiple logical sizes.

At minimum, test:

- Onboarding.
- Login.
- Dashboard.
- Sale form.
- Expense form.
- Product form.
- Cash-flow screen.
- Transaction history.
- Report preview.
- Settings.

Check for render exceptions, overflow errors, clipped primary actions and broken scrolling.

Test orientation changes while a form contains unsaved data.

Use device and emulator testing to complement widget tests; widget tests alone cannot prove universal Android compatibility.

### Release compatibility

- Respect the installed Flutter SDK's supported Android toolchain.
- Declare an appropriate Android minimum SDK.
- Verify the build against the intended target SDK and current tooling requirements.
- Test the generated APK on the available emulator or physical device.
- Ensure release configuration does not depend on development-only assets or secrets.
- Do not claim universal device compatibility; document the actual tested device profiles.

---

# PART 9 — SECURITY, PRIVACY AND RELIABILITY

## 30. Security Requirements

- Use HTTPS for network communication.
- Keep privileged credentials out of the client.
- Enforce backend authorisation through Row Level Security.
- Validate all financial inputs.
- Handle authentication expiry safely.
- Avoid logging sensitive business information.
- Avoid exposing complete financial records in error messages.
- Clear sensitive in-memory and cached state when a user signs out.
- Do not leak one user's information through shared caches.
- Use secure storage for sensitive local tokens where required.
- Provide understandable privacy information.
- Use least-privilege access for backend services.
- Avoid collecting unnecessary personal information.

## 31. Reliability Requirements

The application must handle:

- No internet connection.
- Slow requests.
- Server errors.
- Expired sessions.
- Empty datasets.
- Invalid inputs.
- Repeated button taps.
- Partial synchronisation failures.
- Application restarts.
- Interrupted form entry.
- Large transaction histories.
- Unexpected API responses.

Provide appropriate retry actions and preserve user-entered data whenever it is safe to do so.

Do not show an indefinite loading spinner.

---

# PART 10 — PERFORMANCE AND POLISH

## 32. Performance Requirements

- Keep expensive computations out of frequently rebuilt widget trees.
- Use efficient lists for large transaction histories.
- Avoid unnecessary database requests.
- Cache appropriate data while respecting security boundaries.
- Avoid unnecessary full-screen rebuilds.
- Optimise chart rendering.
- Avoid blocking the UI during PDF generation or expensive processing.
- Use pagination where large datasets require it.
- Inspect Flutter performance tools during final testing.

The app should feel responsive during ordinary usage on affordable Android devices.

## 33. Final UX Polish

Before release, inspect every screen for:

- Consistent typography.
- Consistent spacing.
- Correct iconography.
- Readable financial figures.
- Clear primary actions.
- Appropriate confirmation messages.
- Useful empty states.
- Loading skeletons or progress indicators.
- Friendly error states.
- Accessible contrast.
- Keyboard handling.
- Scroll behaviour.
- Responsive layouts.
- Correct currency and date formatting.
- No placeholder text.
- No unfinished navigation.
- No fake buttons.
- No unhandled exceptions.

The dashboard, transaction-entry flow and cash-flow insight screen deserve the highest visual priority because they communicate the product's core value.

---

# PART 11 — IMPLEMENTATION PLAN

## 34. Development Phases

Cursor must implement the application in stages, running tests at each stage rather than generating the entire application in one unverified pass.

### Phase 0 — Repository audit and plan

- Inspect the repository and environment.
- Check Flutter and Dart versions.
- Review existing code and dependencies.
- Identify missing configuration.
- Create `docs/IMPLEMENTATION_PLAN.md`.
- Create `docs/TEST_PLAN.md`.
- Document architectural decisions.
- Identify the initial MVP boundary.

**Exit criteria:** The implementation plan matches the actual repository and its constraints.

### Phase 1 — Foundation and design system

- Establish project architecture.
- Configure theme and design tokens.
- Implement reusable components.
- Configure routing and state management.
- Configure environment handling.
- Establish error handling and logging.
- Create responsive navigation.
- Add initial widget tests.

**Exit criteria:** The app starts reliably and the shared design system is functional.

### Phase 2 — Onboarding and authentication

- Implement onboarding.
- Implement registration and login.
- Implement session restoration.
- Implement logout and password reset.
- Add protected routes.
- Add authentication tests.

**Exit criteria:** Authentication flows work and protected screens enforce access rules.

### Phase 3 — Business profile and database

- Create database migrations.
- Configure Row Level Security.
- Implement business setup and editing.
- Implement repositories.
- Add persistence and backend tests.

**Exit criteria:** Authenticated users can create, reopen and edit their own business profile securely.

### Phase 4 — Transactions and financial engine

- Implement sales.
- Implement expenses.
- Implement transaction history.
- Implement editing and deletion.
- Implement duplicate prevention.
- Implement financial calculations.
- Add comprehensive unit and integration tests.

**Exit criteria:** Transaction operations persist correctly and all core totals match independent calculations.

### Phase 5 — Dashboard and responsive design

- Implement dashboard metrics.
- Implement recent transactions.
- Implement date-range selection.
- Implement charts and quick actions.
- Test multiple screen sizes and orientations.

**Exit criteria:** Dashboard values are correct and layouts pass responsive tests.

### Phase 6 — Inventory

- Implement product management.
- Implement stock movements.
- Integrate product sales with inventory.
- Implement low-stock recommendations.
- Test data consistency.

**Exit criteria:** Product sales and inventory movements remain consistent after successful and failed operations.

### Phase 7 — Cash-flow intelligence

- Implement obligations.
- Implement deterministic forecasts.
- Implement explainable recommendations.
- Add forecast visualisations.
- Test all financial scenarios.

**Exit criteria:** Forecasts are reproducible, correctly calculated and understandable.

### Phase 8 — Reports and offline support

- Implement report previews.
- Implement PDF generation and sharing.
- Implement offline storage and synchronisation where feasible.
- Test persistence, retry handling and duplicate prevention.

**Exit criteria:** Reports contain correct data; any advertised offline functionality passes its acceptance tests.

### Phase 9 — Quality and competition polish

- Complete responsive testing.
- Run security tests.
- Run automated tests.
- Inspect all screens.
- Fix critical and major defects.
- Prepare demo data.
- Produce a reproducible demonstration flow.
- Generate a release APK.

**Exit criteria:** The build succeeds, core tests pass, no known critical defects remain, and the app can be demonstrated from a clean installation.

---

# PART 12 — REQUIRED DELIVERABLES

## 35. Source Code

Deliver:

- Complete Flutter application source.
- Documented project structure.
- Version-controlled database migrations.
- Secure environment configuration template.
- Reusable design system.
- Unit, widget and integration tests.
- Setup instructions.
- Build instructions.
- Demo-data instructions.
- Troubleshooting guidance.

## 36. Documentation

Create and maintain:

- `README.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/ARCHITECTURE.md`
- `docs/DATABASE_SCHEMA.md`
- `docs/SECURITY.md`
- `docs/TEST_PLAN.md`
- `docs/RESPONSIVE_TEST_MATRIX.md`
- `docs/DEMO_GUIDE.md`
- `docs/KNOWN_LIMITATIONS.md`

Document any feature that is incomplete, any external setup requirement and any test that could not be executed.

## 37. Final Build

Produce a debug build for development and a release APK for demonstration.

Verify that the APK exists at the actual build output path, installs and launches on the available test device, and can complete the core demo flow.

Do not report that an APK is ready unless it was successfully built and its output was verified.

---

# PART 13 — FINAL ACCEPTANCE CHECKLIST

## 38. Definition of Done

The project is not complete until the following conditions have been checked.

### Core functionality

- [ ] Users can register and log in.
- [ ] Users can create and edit a business profile.
- [ ] Users can record sales and expenses.
- [ ] Transactions persist after restarting the app.
- [ ] Duplicate financial submissions are prevented.
- [ ] Financial totals match independently calculated values.
- [ ] Dashboard values update after changes.
- [ ] Products and stock movements work correctly.
- [ ] Cash-flow forecasts are based on recorded data and documented rules.
- [ ] Recommendations explain their supporting evidence.
- [ ] Reports contain correct figures.
- [ ] Error states and retry flows work.

### Security

- [ ] Database Row Level Security is enabled and tested.
- [ ] Cross-user data access attempts fail.
- [ ] No privileged credentials are embedded in the app.
- [ ] Logout clears the active user session and sensitive cached state.
- [ ] Financial operations validate input and preserve data integrity.

### Android and design

- [ ] The application runs on the available Android test device.
- [ ] Key screens pass responsive widget tests.
- [ ] Portrait and landscape layouts work.
- [ ] Small-screen forms remain usable.
- [ ] Large text settings do not make essential actions inaccessible.
- [ ] Keyboard and system insets are handled correctly.
- [ ] No known critical layout overflows remain.
- [ ] The UI uses the same design system across the app.
- [ ] Loading, empty, success and error states are polished.

### Quality

- [ ] `dart format` has been run.
- [ ] `flutter analyze` has been run and reviewed.
- [ ] Unit tests have been run.
- [ ] Widget tests have been run.
- [ ] Integration tests have been run where the environment permits.
- [ ] Database security tests have been run.
- [ ] The final Android build succeeds.
- [ ] Remaining limitations are documented.

### Competition readiness

- [ ] The app opens into a clear, polished first-use experience.
- [ ] A judge can complete the main workflow without developer intervention.
- [ ] The business problem is obvious.
- [ ] The app demonstrates at least one useful, explainable financial insight.
- [ ] Demo data produces consistent and believable results.
- [ ] The presentation avoids claims unsupported by the actual implementation.
- [ ] A short demonstration script is ready.

---

# PART 14 — INITIAL INSTRUCTION TO EXECUTE

Begin now.

First inspect the existing repository, Flutter environment, dependencies and current implementation.

Then create the implementation plan and test plan.

Immediately proceed to Phase 1 and continue through the implementation phases in a practical order. Do not stop after producing documentation or a list of recommendations.

After each phase:

1. Run the relevant formatter and static analysis.
2. Run the tests for the functionality implemented.
3. Fix failures before building further dependent functionality.
4. Update the implementation plan and document completed work.
5. Clearly identify any blocker requiring human input or external credentials.

If the full project cannot be completed in one session, leave the repository in a working state, with the completed phases tested and the remaining work explicitly recorded.

Do not sacrifice financial correctness, security or responsive layouts merely to increase the number of features.

**The final objective is a working, polished Android product that a judge can install, explore and evaluate independently — with evidence that its core features actually work.**
