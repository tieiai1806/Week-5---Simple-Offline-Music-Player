# simple_music_player

Do máy ảo gặp sự cố về quyền truy cập bộ nhớ (Permission denied), em đã cấu hình app sử dụng dữ liệu nhạc mẫu trực tiếp từ thư mục Assets để đảm bảo các tính năng phát nhạc, chuyển bài và giao diện hoạt động ổn định nhất cho việc chấm bài.
<img width="391" height="905" alt="image" src="https://github.com/user-attachments/assets/2382afad-5d86-4d9b-99eb-ce5c8f9b1573" />
<img width="393" height="911" alt="image" src="https://github.com/user-attachments/assets/9735fbe8-3013-499f-964c-4da37b2d2091" />
<img width="394" height="911" alt="image" src="https://github.com/user-attachments/assets/c0853567-29b1-4b3e-a15e-1b759f886f32" />
# PHẦN 1: GIỚI THIỆU CHI TIẾT THƯ VIỆN
*(Mở file `pubspec.yaml`)*

## 🎤 Lời thoại gợi ý

> “Thưa cô, để xây dựng ứng dụng nghe nhạc hoàn chỉnh này, em đã phối hợp nhiều thư viện chuyên biệt nhằm giải quyết các bài toán từ phần cứng đến giao diện.”

---

# 1️⃣ Nhóm Điều Khiển Âm Thanh (Cốt lõi)

## 🔹 `just_audio` & `audio_session`

- Dùng để phát nhạc và quản lý phiên làm việc của âm thanh.
- Ví dụ:
  - Tự động dừng nhạc khi có cuộc gọi đến.
  - Tạm dừng khi có ứng dụng khác phát âm thanh.

---

## 🔹 `audio_service`

- Giúp ứng dụng có thể điều khiển nhạc từ:
  - Màn hình khóa
  - Thanh thông báo của điện thoại

---

# 2️⃣ Nhóm Quản Lý Tệp & Quyền Truy Cập

## 🔹 `on_audio_query`

- Đây là thư viện quan trọng nhất để:
  - Quét toàn bộ các tệp nhạc có trong máy
  - Lấy metadata:
    - Tên bài hát
    - Nghệ sĩ
    - Ảnh bìa album

---

## 🔹 `permission_handler`

- Dùng để xin quyền truy cập bộ nhớ của người dùng một cách an toàn.

---

## 🔹 `file_picker` & `path_provider`

- Cho phép người dùng:
  - Chủ động chọn tệp nhạc từ thư mục bất kỳ
  - Xác định chính xác đường dẫn tệp trong hệ thống

---

# 3️⃣ Nhóm Xử Lý Dữ Liệu & Trạng Thái

## 🔹 `provider`

- Dùng để quản lý trạng thái tập trung *(State Management)*.
- Đảm bảo dữ liệu luôn đồng bộ giữa các màn hình.

---

## 🔹 `rxdart`

- Bổ sung sức mạnh cho các luồng dữ liệu *(Streams)*.
- Giúp kết hợp nhiều luồng thông tin:
  - Thời gian bài hát
  - Trạng thái Play / Pause
  - Thanh tiến trình

---

## 🔹 `shared_preferences`

- Dùng để lưu trữ dữ liệu bền vững *(Persistence)* như:
  - Danh sách yêu thích
  - Playlist
  - Các cài đặt cá nhân

---

# 4️⃣ Nhóm Giao Diện & Hình Ảnh

## 🔹 `palette_generator`

- Giúp phân tích ảnh bìa album.
- Tự động thay đổi màu sắc chủ đạo của giao diện theo bài hát đang phát.

---

## 🔹 `cached_network_image`

- Tối ưu hóa việc tải và lưu tạm hình ảnh từ Internet.
- Giúp ứng dụng:
  - Chạy nhanh hơn
  - Tiết kiệm dữ liệu mạng

---

## 🔹 `cupertino_icons`

- Cung cấp bộ icon theo phong cách iOS.
- Giúp giao diện thêm phần tinh tế.

---

