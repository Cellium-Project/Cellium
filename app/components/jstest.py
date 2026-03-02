# -*- coding: utf-8 -*-
import threading
import time
import logging
from app.core.interface.base_cell import BaseCell

logger = logging.getLogger(__name__)


class JsTest(BaseCell):
    def __init__(self):
        threading.Thread(target=self._run_time_pusher, daemon=True).start()

    def _run_time_pusher(self):
        while True:
            from datetime import datetime
            current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            script = f"document.getElementById('current-time').textContent = '当前时间: {current_time}';"
            self.run_js(script)
            time.sleep(1)
