import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Syarat & Ketentuan',
      updatedAt: '10 September 2026',
      intro:
          'Syarat & Ketentuan ini mengatur penggunaan aplikasi Unity Billiard untuk mencari dan '
          'memesan meja billiard di tempat-tempat rekanan (vendor). Dengan mendaftar dan '
          'menggunakan aplikasi ini, kamu dianggap sudah membaca dan menyetujui seluruh ketentuan '
          'di bawah ini.',
      sections: [
        LegalSection(
          '1. Tentang Layanan',
          'Unity Billiard adalah platform yang mempertemukan pelanggan dengan tempat billiard '
              'rekanan untuk kebutuhan pemesanan meja secara online. Unity Billiard bukan pemilik '
              'atau pengelola tempat billiard yang terdaftar di aplikasi, sehingga kualitas '
              'fasilitas, kebersihan, dan pelayanan di lokasi sepenuhnya menjadi tanggung jawab '
              'masing-masing vendor.',
        ),
        LegalSection(
          '2. Akun Pengguna',
          'Kamu wajib mendaftar menggunakan data diri yang benar dan aktif (nama, email, nomor '
              'HP). Satu akun hanya boleh digunakan oleh satu orang. Kamu bertanggung jawab penuh '
              'menjaga kerahasiaan password dan atas seluruh aktivitas yang terjadi melalui '
              'akunmu. Segera hubungi dukungan pelanggan jika mencurigai akunmu diakses pihak '
              'lain.',
        ),
        LegalSection(
          '3. Pemesanan Meja',
          'Ketersediaan meja, jam operasional, dan harga sewa per jam ditentukan oleh masing-'
              'masing vendor dan dapat berubah sewaktu-waktu. Total pembayaran yang tertera saat '
              'pemesanan sudah termasuk biaya layanan platform. Booking yang berhasil dibuat akan '
              'berstatus "Menunggu Konfirmasi" sampai vendor mengonfirmasi atau pembayaran '
              'terverifikasi.',
        ),
        LegalSection(
          '4. Pembayaran',
          'Pembayaran diproses melalui penyedia jasa pembayaran pihak ketiga. Unity Billiard '
              'tidak menyimpan detail kartu, rekening, atau data pembayaran sensitif lainnya. '
              'Booking yang belum dibayar dapat dibatalkan otomatis maupun manual apabila batas '
              'waktu pembayaran terlewati.',
        ),
        LegalSection(
          '5. Pembatalan oleh Pelanggan',
          'Kamu dapat membatalkan booking yang masih berstatus "Menunggu Konfirmasi" atau '
              '"Dikonfirmasi" selama jam mulai booking belum lewat, langsung dari aplikasi. '
              'Pembatalan bersifat final dan tidak dapat dibatalkan kembali. Perlu diketahui, '
              'pembatalan tidak secara otomatis memproses pengembalian dana atas pembayaran yang '
              'sudah masuk - untuk pengembalian dana, hubungi dukungan pelanggan atau vendor '
              'terkait, mengikuti kebijakan pengembalian dana yang berlaku di vendor tersebut.',
        ),
        LegalSection(
          '6. Pembatalan oleh Vendor',
          'Vendor berhak menolak atau membatalkan booking dalam situasi tertentu, misalnya '
              'kendala meja atau operasional mendadak. Kamu akan mendapat notifikasi melalui '
              'aplikasi apabila hal ini terjadi.',
        ),
        LegalSection(
          '7. Perilaku Pengguna',
          'Kamu dilarang menyalahgunakan aplikasi, termasuk namun tidak terbatas pada membuat '
              'pemesanan fiktif, memanipulasi promo, atau mengganggu pengguna dan vendor lain. '
              'Unity Billiard berhak menangguhkan atau menonaktifkan akun yang terbukti melanggar '
              'ketentuan ini.',
        ),
        LegalSection(
          '8. Ulasan',
          'Ulasan hanya dapat diberikan untuk booking yang sudah berstatus "Selesai". Ulasan '
              'harus mencerminkan pengalaman nyata dan tidak boleh memuat konten yang menyesatkan, '
              'menyerang pihak lain, atau melanggar hukum yang berlaku.',
        ),
        LegalSection(
          '9. Batasan Tanggung Jawab',
          'Unity Billiard bertindak sebagai perantara antara pelanggan dan vendor. Kami tidak '
              'bertanggung jawab atas kejadian yang timbul di lokasi venue, seperti kecelakaan, '
              'kehilangan barang, atau sengketa layanan di tempat. Sengketa antara pelanggan dan '
              'vendor sebaiknya diselesaikan langsung dengan pihak terkait; Unity Billiard dapat '
              'membantu memfasilitasi apabila diperlukan.',
        ),
        LegalSection(
          '10. Perubahan Ketentuan',
          'Syarat & Ketentuan ini dapat diperbarui sewaktu-waktu. Versi terbaru akan berlaku '
              'sejak dipublikasikan di dalam aplikasi, dan penggunaan aplikasi setelah perubahan '
              'berarti kamu menyetujui ketentuan yang telah diperbarui.',
        ),
        LegalSection(
          '11. Kontak',
          'Ada pertanyaan tentang Syarat & Ketentuan ini? Hubungi tim dukungan pelanggan Unity '
              'Billiard melalui support@unitybilliard.id.',
        ),
      ],
    );
  }
}
