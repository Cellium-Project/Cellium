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
    def cell_name(self):
        return "jstest"
    
    def get_commands(self):
        return {
            "delay": "模拟耗时任务",
            "echo": "回显测试"
        }
    
    def _cmd_delay(self, seconds: int = 3):
        if isinstance(seconds, str):
            seconds = int(seconds)
        time.sleep(seconds)
        self.run_js(f"console.log('耗时任务完成，耗时 {seconds} 秒')")
        self.run_js(f"document.getElementById('event-log').querySelector('.log-content').innerHTML = '<div class=\"log-entry\">耗时任务完成，耗时 {seconds} 秒</div>' + document.getElementById('event-log').querySelector('.log-content').innerHTML;")
        return None
    
    def _cmd_echo(self, message: str = ""):
        self.run_js(f"console.log('Echo: {message}')")
        return f"Echo: {message}"
    
    def _run_time_pusher(self):
        while True:
            from datetime import datetime
            current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            script = f"document.getElementById('current-time').textContent = '当前时间: {current_time}';"
            self.run_js(script)
            time.sleep(1)
