"""Seamless directional navigation between terminal apps and Kitty splits."""

from typing import Any

from kittens.tui.handler import result_handler
from kitty.boss import Boss
from kitty.window import Window


NAVIGATION_VARIABLE = "tmux_kitty_navigate"
VALID_DIRECTIONS = frozenset(("left", "right", "top", "bottom"))


def main(args: list[str]) -> None:
    pass


def _focus_neighbor(boss: Boss, window: Window, direction: str) -> None:
    if direction not in VALID_DIRECTIONS:
        return

    boss.call_remote_control(
        window,
        ("focus-window", "--no-response", f"--match=neighbor:{direction}"),
    )


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    """Pass navigation into a full-screen app, otherwise navigate Kitty."""
    window = boss.window_id_map.get(target_window_id)
    if window is None or len(args) < 3:
        return

    direction, key = args[1:3]
    if direction not in VALID_DIRECTIONS:
        return

    if not window.screen.is_main_linebuf():
        boss.call_remote_control(
            window,
            ("send-key", f"--match=id:{window.id}", key),
        )
    else:
        _focus_neighbor(boss, window, direction)


def on_set_user_var(
    boss: Boss, window: Window, data: dict[str, Any]
) -> None:
    """Accept a narrow navigation request emitted through a local or SSH tmux."""
    if data.get("key") == NAVIGATION_VARIABLE:
        _focus_neighbor(boss, window, data.get("value", ""))
