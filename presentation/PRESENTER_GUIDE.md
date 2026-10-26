# Presenter guide — Kgwebo, FNB App of the Year 2026

Target: about 8 minutes. Credentials are on slides 1 and 12.

**Judge login:** `dreu.davids1@gmail.com` / `password` · stall DreuTech (illustrative ZAR records)

## 1 — Cover

Kgwebo helps a stall see the cash it actually has. Point at the live Home screenshot. Read the demo login once.

## 2 — Problem

Notebooks, mixed till cash, surprise bills, no next step. Call these hypotheses. Do not invent market size.

## 3 — Solution

Record → understand → anticipate → act. Name what already works: ledger, stock, bills, recommendations, Ask, reports.

## 4 — How it works

Four screens. Offline is limited: amount-only creates and new unpaid bills. Pending is not cash. Product sales need a network.

## 5 — The incident

Tell the WhatsApp first. Supplier offers ten USB-C hubs for R 4,000 cash. Till shows R 31,840. Rent is R 5,500 on 1 Nov, Adobe R 890 on 5 Nov. Label DreuTech illustrative. The question: can Dreu restock and still pay rent?

## 6 — Same morning

Walk Home → Bills → Stock → Ask as one decision. After known bills: R 25,450. Restock still fits. The R 450 website fix is a draft until Confirm — say that out loud.

## 7 — Product close-up

Let the screenshots talk. Cash on Home, the ledger, the forecast drop, Ask’s Confirm button.

## 8 — Intelligence

Cash ≠ sales. The till is not free cash. Unpaid bills sit in the outlook. Stock value is not cash. Ask is grounded in FinancialEngine and can be wrong.

## 9 — Architecture (stack)

Top to bottom: widgets do not calculate; one money engine; pending is not cash; FORCE RLS and inventory RPCs in Postgres; Ask is an Edge Function, not a writer. No bank feeds on this slide.

## 10 — Architecture (two paths)

Left: recording a sale, including the honest outbox. Right: Ask classifies, snapshots, calls `kgwebo-copilot`, grounds, then Confirm. The model is a parser. The ledger is the source of truth.

## 11 — Impact

Tie each line back to Dreu’s morning. No testimonials or user counts.

## 12 — Close

“Every business deserves a clearer picture of its money.” Repeat the login. Offer a live Ask demo if there is time.
