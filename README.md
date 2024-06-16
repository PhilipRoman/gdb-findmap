# FindMap

This python script adds a new commmand `findmap`, which parses the output of `info proc mappings` and finds the
origin file plus offset which is mapped at the given address.

## Usage

```gdb
>>> source gdb-findmap.py
>>> findmap malloc(1)
Mapping:
          Start Addr           End Addr       Size     Offset  Perms  objfile
      0x5555555a7000     0x5555555c8000    0x21000        0x0  rw-p   [heap]
Origin: [heap] + 0x300
>>> findmap sin
Mapping:
          Start Addr           End Addr       Size     Offset  Perms  objfile
      0x7ffff7eac000     0x7ffff7f2c000    0x80000     0xe000  r-xp   /usr/lib/libm.so.6
Origin: /usr/lib/libm.so.6 + 0x2f250
>>> findmap $rsp
Mapping:
          Start Addr           End Addr       Size     Offset  Perms  objfile
      0x7ffffffdd000     0x7ffffffff000    0x22000        0x0  rw-p   [stack]
Origin: [stack] + 0x20998
```
