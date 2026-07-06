# Musleem - a free, clean, and simple muslim prayer reminder and guide
![stars](https://img.shields.io/github/stars/itzfurizugg/MuslimNoob) ![forks](https://img.shields.io/github/forks/itzfurizugg/MuslimNoob) ![downloads](https://img.shields.io/github/downloads/itzfurizugg/MuslimNoob/total) ![flutter](https://img.shields.io/badge/flutter-enabled-02569B?logo=flutter&logoColor=white)

---

## Apa itu Musleem?
Musleem adalah aplikasi pengingat ibadah yang dibuat untuk pengguna Android dengan Flutter, terintegrasi dengan API dari [EQuran.id](https://equran.id) dan database pengguna berbasis Supabase. Musleem menawarkan fitur utama berupa:

🕐 Melihat jadwal sholat berdasarkan kota
🧭 Mengetahui arah kiblat secara real-time
📿 Membaca doa harian dan dzikir
📖 Mempelajari tata cara ibadah step-by-step
🔔 Mendapatkan notifikasi azan otomatis
📚 Mengakses panduan sholat lengkap dengan teks arab dan latin

---

## Fitur Utama

### 🕐 Jadwal Sholat
- Jadwal sholat berdasarkan kota/wilayah
- Data dari database Supabase (sumber: KEMENAG RI)
- Picker kota yang mudah digunakan

### 🔔 Notifikasi Azan
- Notifikasi lokal otomatis menggunakan `awesome_notifications`
- Dijadwalkan langsung dari device tanpa server push
- Dapat dikustomisasi per waktu sholat

### 🧭 Kompas Kiblat
- Arah kiblat real-time menggunakan sensor kompas
- Deteksi lokasi otomatis via GPS
- Visualisasi kompas yang intuitif

### 📿 Doa & Dzikir
- Kategori: Doa Harian, Dzikir, Lainnya
- Data diambil dari **API EQuran.id** (teks arab, transliterasi, dan terjemahan)
- Konten tambahan dikelola dari admin web

### 📖 Tata Cara Ibadah
- Panduan step-by-step dengan foto
- Teks arab dan latin per langkah
- Konten: Tata Cara Sholat, Wudhu, Memandikan Jenazah, dll

### 👤 Autentikasi
- Register & login dengan email + OTP
- Email dikirim via Gmail SMTP / Resend
- Session management & database pengguna menggunakan **Supabase Auth + PostgreSQL**

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|-------|-----------|
| **Mobile** | Flutter (Dart) |
| **Konten Doa/Quran** | [EQuran.id API](https://equran.id) |
| **Database & Auth Pengguna** | Supabase (PostgreSQL + Auth + Realtime) |
| **Admin Web** | Vite + React (JavaScript) |
| **Deploy Admin** | Vercel |
| **Email** | Gmail SMTP / Resend |
| **Notifikasi** | awesome_notifications |
| **Kompas** | flutter_compass + geolocator |

---
