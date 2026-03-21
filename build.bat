@echo off
cd /d "%~dp0"
if not exist "dist" mkdir dist

python -m nuitka --standalone --onefile ^
--windows-console-mode=attach ^
--windows-icon-from-ico=app_icon.ico ^
--output-dir="dist" ^
--output-filename="Cellium.exe" ^
--company="Cellium App" ^
--product-name="Cellium App" ^
--file-version=1.0.0.0 ^
--product-version=1.0.0.0 ^
--copyright="Copyright (c) 2026 Cellium Contributors" ^
--lto=auto ^
--remove-output ^
--enable-plugin=tk-inter ^
--include-package=app ^
--include-package=app.core ^
--include-package=app.components ^
--include-package=tkinter ^
--include-package=tkinter.ttk ^
--include-package=tkinter.filedialog ^
--include-package=openpyxl ^
--include-package=openpyxl.styles ^
--include-data-files="dll/mb132_x64.dll=dll/mb132_x64.dll" ^
--include-data-files="logo.png=logo.png" ^
--include-data-dir="html=html" ^
--include-data-dir="config=config" ^
--include-data-files="app_icon.ico=app_icon.ico" ^
main.py

pause
