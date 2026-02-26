# -*- coding: utf-8 -*-
import threading
import time
import logging
from app.core.interface.base_cell import BaseCell

logger = logging.getLogger(__name__)


class JsTest(BaseCell):
    def __init__(self):
        threading.Thread(target=self._run_time_pusher, daemon=True).start()

    @property
    def cell_name(self) -> str:
        return "jstest"

    def _run_time_pusher(self):
        while True:
            from app.core.window import MainWindow
            window = MainWindow.get_instance()
            if window and hasattr(window, 'bridge') and window.bridge:
                from datetime import datetime
                current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                script = f"document.getElementById('current-time').textContent = '当前时间: {current_time}';"
                window.bridge.send_to_js(script)
                time.sleep(60)
            else:
                time.sleep(1)
