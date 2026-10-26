"""Capture remaining presentation screens from the signed-in emulator."""

from __future__ import annotations

import time

from _adb_cap import capture, key, swipe, tap, tap as tap_xy, dump_ui, type_text

# Compact nav bar centres on 1080x2364
HOME = (124, 2199)
MONEY = (332, 2199)
STOCK = (540, 2199)
ASK = (748, 2199)
MORE = (956, 2199)


def wait(seconds: float) -> None:
    time.sleep(seconds)


def main() -> None:
    tap(*HOME)
    wait(0.8)
    tap(540, 1097)  # Record a sale
    wait(1.4)
    capture("02-record-sale.png")
    key("KEYCODE_BACK")
    wait(1.0)

    tap(*MONEY)
    wait(3.0)
    capture("03-money-history.png")

    tap(*STOCK)
    wait(1.6)
    capture("05-stock.png")

    tap(*MORE)
    wait(1.1)
    tap(540, 605)  # Bills row
    wait(2.0)
    capture("04-cash-flow.png")

    tap(*HOME)
    wait(1.0)
    swipe(540, 1900, 540, 650)
    wait(0.5)
    swipe(540, 1900, 540, 650)
    wait(0.8)
    capture("06-recommendations.png")

    tap(*ASK)
    wait(1.5)
    capture("07-ask-intro.png")


if __name__ == "__main__":
    main()
