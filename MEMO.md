# Custom Key Map Set for Windows
- Win + R -> regedit
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout
- Make new binary file named `ScanCode Map`
- Type following
```
00 00 00 00 00 00 00 00
02 00 00 00 1D 00 3A 00
00 00 00 00
```
