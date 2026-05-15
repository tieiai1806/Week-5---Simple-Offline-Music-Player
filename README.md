# simple_music_player

Do máy ảo gặp sự cố về quyền truy cập bộ nhớ (Permission denied), em đã cấu hình app sử dụng dữ liệu nhạc mẫu trực tiếp từ thư mục Assets để đảm bảo các tính năng phát nhạc, chuyển bài và giao diện hoạt động ổn định nhất cho việc chấm bài.
<img width="391" height="905" alt="image" src="https://github.com/user-attachments/assets/2382afad-5d86-4d9b-99eb-ce5c8f9b1573" />
<img width="393" height="911" alt="image" src="https://github.com/user-attachments/assets/9735fbe8-3013-499f-964c-4da37b2d2091" />
<img width="394" height="911" alt="image" src="https://github.com/user-attachments/assets/c0853567-29b1-4b3e-a15e-1b759f886f32" />
PHẦN 1: GIỚI THIỆU CHI TIẾT THƯ VIỆN (Mở file pubspec.yaml)
Thưa cô, để xây dựng ứng dụng nghe nhạc hoàn chỉnh này, em đã phối hợp nhiều thư viện chuyên biệt nhằm giải quyết các bài toán từ phần cứng đến giao diện:
1. Nhóm Điều khiển Âm thanh:
•	just_audio & audio_session: "Dùng để phát nhạc và quản lý phiên làm việc của âm thanh (ví dụ: tự động dừng nhạc khi có cuộc gọi đến)."
•	audio_service: "Giúp ứng dụng có thể điều khiển nhạc từ màn hình khóa hoặc thanh thông báo của điện thoại."
2. Nhóm Quản lý Tệp & Quyền truy cập:
•	on_audio_query: "Đây là thư viện quan trọng nhất để quét toàn bộ các tệp nhạc có trong máy và lấy ra các thông tin metadata như tên bài hát, nghệ sĩ, ảnh bìa album."
•	permission_handler: "Em dùng để xin quyền truy cập bộ nhớ của người dùng một cách an toàn."
•	file_picker & path_provider: "Cho phép người dùng chủ động chọn tệp nhạc từ thư mục bất kỳ và xác định chính xác đường dẫn tệp trong hệ thống."
3. Nhóm Xử lý Dữ liệu & Trạng thái:
•	provider: "Dùng để quản lý trạng thái tập trung (State Management), đảm bảo dữ liệu luôn đồng bộ giữa các màn hình."
•	rxdart: "Bổ sung sức mạnh cho các luồng dữ liệu (Streams), giúp em kết hợp nhiều luồng thông tin (như thời gian bài hát và trạng thái Play/Pause) một cách mượt mà."
•	shared_preferences: "Dùng để lưu trữ dữ liệu bền vững (Persistence) như danh sách yêu thích, Playlist và các cài đặt cá nhân."
4. Nhóm Giao diện & Hình ảnh:
•	palette_generator: "Giúp em phân tích ảnh bìa album để tự động thay đổi màu sắc chủ đạo của giao diện theo bài hát đang phát."
•	cached_network_image: "Tối ưu hóa việc tải và lưu tạm hình ảnh từ Internet, giúp app chạy nhanh hơn và tiết kiệm dữ liệu."
•	cupertino_icons: "Cung cấp bộ icon theo phong cách iOS để giao diện thêm phần tinh tế."
