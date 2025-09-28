# FF
### FFmpeg Auto Build

# FF docker
### 由于存在以下依赖问题，需使用 debian slim，而不是alpine
```log
7zz: ld-linux-x86-64.so.2 | ...
```
```log
ffmpeg: libmvec.so.1 | libgcc_s.so.1 | ld-linux-x86-64.so.2 | ...
```
