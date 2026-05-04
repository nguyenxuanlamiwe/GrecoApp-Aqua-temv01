# Hướng dẫn cài đặt Android SDK (Không cần Android Studio)

## Bước 1: Tải Android Command Line Tools

1. Truy cập: https://developer.android.com/studio#command-line-tools-only
2. Tải file **commandlinetools-win-xxxxx_latest.zip**
3. Giải nén vào thư mục: `C:\Android\cmdline-tools`
4. Sau khi giải nén, cấu trúc thư mục phải như sau:
   ```
   C:\Android\cmdline-tools\latest\bin\
   C:\Android\cmdline-tools\latest\lib\
   ```

## Bước 2: Thiết lập biến môi trường

### Tạo biến ANDROID_HOME:
1. Nhấn `Windows + X` → **System** → **Advanced system settings**
2. Nhấn **Environment Variables**
3. Trong **System variables**, nhấn **New**:
   - Tên biến: `ANDROID_HOME`
   - Giá trị: `C:\Android`
4. Nhấn **OK**

### Thêm vào PATH:
Trong **System variables**, tìm **Path** → **Edit** → **New**, thêm:
```
%ANDROID_HOME%\cmdline-tools\latest\bin
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\emulator
```

## Bước 3: Cài đặt SDK Platform-Tools qua sdkmanager

Mở **PowerShell** hoặc **Command Prompt** MỚI (để load biến môi trường):

```powershell
# Chấp nhận licenses
sdkmanager --licenses

# Cài đặt Platform-Tools
sdkmanager "platform-tools"

# Cài đặt Build Tools
sdkmanager "build-tools;34.0.0"

# Cài đặt Android Platform (API 34)
sdkmanager "platforms;android-34"

# Cài đặt Emulator (tùy chọn)
sdkmanager "emulator"

# Cài đặt System Image cho Emulator (tùy chọn)
sdkmanager "system-images;android-34;google_apis;x86_64"
```

## Bước 4: Kiểm tra cài đặt

```powershell
# Kiểm tra adb (từ platform-tools)
adb version

# Kiểm tra sdkmanager
sdkmanager --version

# Liệt kê packages đã cài
sdkmanager --list_installed
```

## Bước 5: Cài đặt Java Development Kit (JDK)

Flutter yêu cầu JDK 11 hoặc mới hơn:

1. Tải JDK từ: https://adoptium.net/
2. Cài đặt JDK
3. Thêm biến môi trường:
   - `JAVA_HOME` = `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`
   - Thêm vào PATH: `%JAVA_HOME%\bin`

## Kiểm tra sau khi cài đặt

Mở PowerShell mới và chạy:
```powershell
flutter doctor
```

Kết quả mong muốn:
- ✅ Flutter
- ✅ Android toolchain
- ✅ VS Code
