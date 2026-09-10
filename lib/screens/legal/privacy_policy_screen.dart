import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Kebijakan Privasi',
      updatedAt: '10 September 2026',
      intro:
          'Kebijakan Privasi ini menjelaskan bagaimana Unity Billiard mengumpulkan, menggunakan, '
          'dan melindungi data pribadimu saat menggunakan aplikasi ini.',
      sections: [
        LegalSection(
          '1. Data yang Kami Kumpulkan',
          'Kami mengumpulkan data yang kamu berikan saat mendaftar dan menggunakan aplikasi: '
              'nama, email, nomor HP, dan password (tersimpan dalam bentuk terenkripsi). Kami '
              'juga menyimpan riwayat pemesanan, status pembayaran, dan ulasan yang kamu buat.',
        ),
        LegalSection(
          '2. Penggunaan Data',
          'Data yang kami kumpulkan digunakan untuk memproses pemesanan dan pembayaran, '
              'mengirim notifikasi terkait booking (konfirmasi, pengingat, pembatalan), '
              'meningkatkan kualitas layanan, serta mengirimkan informasi promo yang dapat kamu '
              'matikan kapan saja melalui pengaturan notifikasi.',
        ),
        LegalSection(
          '3. Pembagian Data ke Vendor',
          'Saat kamu membuat booking, nama dan nomor HP dibagikan ke vendor tempat kamu '
              'memesan agar vendor dapat menghubungi atau memverifikasi kehadiranmu. Vendor '
              'wajib menjaga kerahasiaan data tersebut dan hanya boleh menggunakannya untuk '
              'keperluan pemesanan yang bersangkutan.',
        ),
        LegalSection(
          '4. Pembagian Data ke Pihak Ketiga',
          'Proses pembayaran ditangani oleh penyedia jasa pembayaran pihak ketiga. Unity '
              'Billiard tidak menyimpan detail kartu, rekening, atau data pembayaran sensitif '
              'lainnya - data tersebut diproses langsung oleh penyedia pembayaran sesuai '
              'kebijakan privasi mereka sendiri.',
        ),
        LegalSection(
          '5. Penyimpanan & Keamanan Data',
          'Password kamu disimpan dalam bentuk terenkripsi (hash) dan tidak pernah dapat dilihat '
              'dalam bentuk aslinya, termasuk oleh tim kami. Kami mengambil langkah-langkah wajar '
              'untuk melindungi data dari akses yang tidak sah, namun perlu diingat bahwa tidak '
              'ada sistem yang sepenuhnya bebas risiko.',
        ),
        LegalSection(
          '6. Hak Kamu atas Data',
          'Kamu dapat melihat dan memperbarui data pribadimu (nama, email, nomor HP, password) '
              'kapan saja melalui menu Edit Profil di aplikasi. Untuk permintaan penghapusan akun '
              'beserta datanya, silakan hubungi dukungan pelanggan.',
        ),
        LegalSection(
          '7. Retensi Data',
          'Data kamu disimpan selama akun masih aktif. Setelah akun dihapus, sebagian data '
              'seperti riwayat transaksi dapat tetap disimpan untuk jangka waktu tertentu sesuai '
              'kebutuhan pembukuan dan kewajiban hukum yang berlaku.',
        ),
        LegalSection(
          '8. Perubahan Kebijakan',
          'Kebijakan Privasi ini dapat diperbarui dari waktu ke waktu. Perubahan akan '
              'diinformasikan melalui aplikasi, dan penggunaan aplikasi setelah perubahan berarti '
              'kamu menyetujui kebijakan yang telah diperbarui.',
        ),
        LegalSection(
          '9. Kontak',
          'Ada pertanyaan tentang privasi datamu? Hubungi tim dukungan pelanggan Unity Billiard '
              'melalui support@unitybilliard.id.',
        ),
      ],
    );
  }
}
