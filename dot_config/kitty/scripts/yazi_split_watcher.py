from typing import Any

from kitty.boss import Boss
from kitty.window import Window


def on_close(boss: Boss, window: Window, data: dict[str, Any])-> None:
    boss.call_remote_control(window, ('action', f'--m=id:{window.id}','layout_action', 'bias', '50'))
