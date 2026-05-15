# simple_music_player

Do máy ảo gặp sự cố về quyền truy cập bộ nhớ (Permission denied), em đã cấu hình app sử dụng dữ liệu nhạc mẫu trực tiếp từ thư mục Assets để đảm bảo các tính năng phát nhạc, chuyển bài và giao diện hoạt động ổn định nhất cho việc chấm bài.
<img width="391" height="905" alt="image" src="https://github.com/user-attachments/assets/2382afad-5d86-4d9b-99eb-ce5c8f9b1573" />
<img width="393" height="911" alt="image" src="https://github.com/user-attachments/assets/9735fbe8-3013-499f-964c-4da37b2d2091" />
<img width="394" height="911" alt="image" src="https://github.com/user-attachments/assets/c0853567-29b1-4b3e-a15e-1b759f886f32" />

# PHẦN 1: GIỚI THIỆU CHI TIẾT THƯ VIỆN
*(Mở file `pubspec.yaml`)*
> "Thưa cô, để xây dựng ứng dụng nghe nhạc hoàn chỉnh này, em đã phối hợp nhiều thư viện chuyên biệt nhằm giải quyết các bài toán từ phần cứng đến giao diện:"
---
# 1. Nhóm Điều khiển Âm thanh (Cốt lõi):
- `just_audio` & `audio_session`:  
  "Dùng để phát nhạc và quản lý phiên làm việc của âm thanh (ví dụ: tự động dừng nhạc khi có cuộc gọi đến)."
- `audio_service`:  
  "Giúp ứng dụng có thể điều khiển nhạc từ màn hình khóa hoặc thanh thông báo của điện thoại."
---
# 2. Nhóm Quản lý Tệp & Quyền truy cập:
- `on_audio_query`:  
  "Đây là thư viện quan trọng nhất để quét toàn bộ các tệp nhạc có trong máy và lấy ra các thông tin metadata như tên bài hát, nghệ sĩ, ảnh bìa album."
- `permission_handler`:  
  "Em dùng để xin quyền truy cập bộ nhớ của người dùng một cách an toàn."
- `file_picker` & `path_provider`:  
  "Cho phép người dùng chủ động chọn tệp nhạc từ thư mục bất kỳ và xác định chính xác đường dẫn tệp trong hệ thống."
---
# 3. Nhóm Xử lý Dữ liệu & Trạng thái:
- `provider`:  
  "Dùng để quản lý trạng thái tập trung (State Management), đảm bảo dữ liệu luôn đồng bộ giữa các màn hình."
- `rxdart`:  
  "Bổ sung sức mạnh cho các luồng dữ liệu (Streams), giúp em kết hợp nhiều luồng thông tin (như thời gian bài hát và trạng thái Play/Pause) một cách mượt mà."
- `shared_preferences`:  
  "Dùng để lưu trữ dữ liệu bền vững (Persistence) như danh sách yêu thích, Playlist và các cài đặt cá nhân."
---
# 4. Nhóm Giao diện & Hình ảnh:
- `palette_generator`:  
  "Giúp em phân tích ảnh bìa album để tự động thay đổi màu sắc chủ đạo của giao diện theo bài hát đang phát."
- `cached_network_image`:  
  "Tối ưu hóa việc tải và lưu tạm hình ảnh từ Internet, giúp app chạy nhanh hơn và tiết kiệm dữ liệu."
- `cupertino_icons`:  
  "Cung cấp bộ icon theo phong cách iOS để giao diện thêm phần tinh tế."

  
| Thư mục / File | Chức năng chính |
|---|---|
| `main.dart` | Điểm khởi chạy ứng dụng. Nơi cấu hình các Provider (quản lý trạng thái) và thiết lập màn hình đầu tiên. |
| 📂 `models/` | Tầng định nghĩa dữ liệu. Quy định cấu trúc (khuôn mẫu) cho dữ liệu bài hát, danh sách phát và trạng thái trình phát. |
| ├─ `song_model.dart` | Định nghĩa các thuộc tính bài hát (ID, tiêu đề, nghệ sĩ, đường dẫn tệp...). |
| ├─ `playlist_model.dart` | Định nghĩa cấu trúc của một danh sách phát (Tên playlist, danh sách các bài hát bên trong). |
| └─ `playback_state_model.dart` | Quản lý trạng thái hiện tại của trình phát (đang chạy ở giây thứ mấy, tổng thời gian...). |
| 📂 `services/` | Tầng thực thi (Dịch vụ). Nơi chứa code tương tác trực tiếp với phần cứng hoặc thư viện bên ngoài. |
| ├─ `audio_player_service.dart` | Điều khiển thư viện just_audio (Play, Pause, Seek, Volume). |
| ├─ `storage_service.dart` | Sử dụng SharedPreferences để lưu dữ liệu bài hát yêu thích và playlist xuống bộ nhớ máy (Persistence). |
| ├─ `permission_service.dart` | Xử lý yêu cầu cấp quyền truy cập bộ nhớ từ người dùng. |
| └─ `playlist_service.dart` | Các logic chuyên sâu về xử lý tệp danh sách phát. |
| 📂 `providers/` | Tầng quản lý trạng thái (ViewModel). Kết nối dữ liệu từ Services để truyền lên giao diện. |
| ├─ `audio_provider.dart` | Bộ não chính của App. Điều khiển logic phát nhạc, chuyển bài, trộn bài (Shuffle). |
| ├─ `playlist_provider.dart` | Quản lý việc tạo mới, thêm bài hoặc xóa bài khỏi playlist của người dùng. |
| ├─ `theme_provider.dart` | Quản lý chế độ giao diện (Sáng/Tối) của ứng dụng. |
| └─ `song_provider.dart` | Quản lý danh sách toàn bộ bài hát đã quét được trong thiết bị. |
| 📂 `screens/` | Giao diện màn hình chính. Chứa các trang hoàn chỉnh mà người dùng nhìn thấy. |
| ├─ `home_screen.dart` | Giao diện chính chứa các Tab (Home, Search, Library). |
| ├─ `now_playing_screen.dart` | Màn hình phát nhạc chi tiết (có đĩa xoay, thanh tiến trình, nút điều khiển lớn). |
| ├─ `all_songs_screen.dart` | Danh sách hiển thị toàn bộ bài hát có trong máy. |
| └─ `playlist_screen.dart` | Màn hình hiển thị nội dung của một playlist cụ thể. |
| 📂 `widgets/` | Thành phần giao diện nhỏ. Các khối UI được tách ra để tái sử dụng. |
| ├─ `song_tile.dart` | Giao diện cho một dòng bài hát trong danh sách. |
| ├─ `mini_player.dart` | Thanh nhạc nhỏ nằm dưới cùng khi người dùng thoát màn hình chính. |
| ├─ `player_controls.dart` | Nhóm các nút Play, Pause, Next, Previous. |
| └─ `progress_bar.dart` | Thanh trượt hiển thị tiến trình bài hát đang chạy. |
| 📂 `utils/` | Công cụ tiện ích. Các hàm bổ trợ xử lý dữ liệu thô. |
| ├─ `duration_formatter.dart` | Chuyển đổi Mili giây sang định dạng phút:giây để hiển thị. |
| ├─ `color_extractor.dart` | Lấy màu sắc từ ảnh album để thay đổi màu nền giao diện theo bài hát. |
| └─ `constants.dart` | Lưu các hằng số dùng chung toàn app (Màu sắc, kích thước, API key...). |


# PHẦN 2: Hành động bấm trên giao diện (UI) và vị trí code.
# 1. Luồng Phát nhạc (Core Playback)

| Thao tác trên App | Vị trí File (UI/Widget) | Vị trí xử lý Logic (Provider/Service) |
|---|---|---|
| Bấm chọn một bài hát để nghe | `song_tile.dart` | `audio_provider.dart` -> hàm `setPlaylist()` hoặc `play()` |
| Bấm nút Play/Pause | `player_controls.dart` | `audio_player_service.dart` -> lệnh `player.play()` / `player.pause()` |
| Bấm nút Next/Previous | `player_controls.dart` | `audio_provider.dart` -> hàm `next()` / `previous()` |
| Bấm nút Shuffle (Trộn bài) | `now_playing_screen.dart` | `audio_provider.dart` -> hàm `toggleShuffle()` |

---

# 2. Quản lý Playlist & Yêu thích

| Thao tác trên App | Vị trí File (UI/Widget) | Vị trí xử lý Logic (Provider/Service) |
|---|---|---|
| Bấm "Thả tim" bài hát | `song_tile.dart` hoặc `now_playing_screen.dart` | `storage_service.dart` -> Lưu vào SharedPreferences |
| Tạo Playlist mới | `playlist_screen.dart` | `playlist_provider.dart` -> hàm `createPlaylist()` |
| Thêm bài vào Playlist | `all_songs_screen.dart` (Menu 3 chấm) | `playlist_service.dart` -> hàm xử lý thêm/xóa tệp |

---

# 3. Giao diện & Tiện ích (UI & Utils)

| Thao tác trên App | Vị trí File (UI/Widget) | Vị trí xử lý Logic (Utils/Service) |
|---|---|---|
| Kéo thanh tiến trình (Seek) | `progress_bar.dart` | `audio_player_service.dart` -> lệnh `player.seek()` |
| Nhìn thấy thời gian chạy (03:45) | `progress_bar.dart` | `duration_formatter.dart` -> hàm chuyển đổi định dạng |
| Màu nền đổi theo ảnh bìa | `now_playing_screen.dart` | `color_extractor.dart` -> dùng `palette_generator` để lấy màu |
| Bấm thanh nhạc nhỏ ở dưới | `mini_player.dart` | `now_playing_screen.dart` -> Điều hướng (`Navigator.push`) |

---

# 4. Cài đặt & Quyền truy cập

| Thao tác trên App | Vị trí File (UI/Widget) | Vị trí xử lý Logic (Provider/Service) |
|---|---|---|
| Đổi chế độ Sáng/Tối | `settings_screen.dart` | `theme_provider.dart` -> hàm `toggleTheme()` |
| Cấp quyền truy cập bộ nhớ | Hiện lên khi mở app hoặc ở Settings | `permission_service.dart` -> dùng `permission_handler` |
| Quét lại danh sách nhạc | Nút Refresh ở `all_songs_screen.dart` | `song_provider.dart` -> dùng `on_audio_query` để quét lại |
