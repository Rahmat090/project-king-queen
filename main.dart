import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'pages/staff_login_page.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KingQueenApp());
}

const brown = Color(0xFF4E342E);
const cream = Color(0xFFFFF8EF);
const gold = Color(0xFFD6A15D);

class TableInfo {
  final String name;
  final String type;
  final String code;

  const TableInfo({
    required this.name,
    required this.type,
    required this.code,
  });
}

const Map<String, TableInfo> daftarMeja = {
  'KQ-TABLE-01': TableInfo(
    name: 'Meja 01',
    type: 'Reguler',
    code: 'KQ-TABLE-01',
  ),
  'KQ-TABLE-02': TableInfo(
    name: 'Meja 02',
    type: 'Reguler',
    code: 'KQ-TABLE-02',
  ),
  'KQ-TABLE-03': TableInfo(
    name: 'Meja 03',
    type: 'Reguler',
    code: 'KQ-TABLE-03',
  ),
  'KQ-TABLE-04': TableInfo(
    name: 'Meja 04',
    type: 'Reguler',
    code: 'KQ-TABLE-04',
  ),
  'KQ-TABLE-05': TableInfo(
    name: 'Meja 05',
    type: 'Reguler',
    code: 'KQ-TABLE-05',
  ),
  'KQ-VIP-01': TableInfo(
    name: 'Meja VIP',
    type: 'VIP',
    code: 'KQ-VIP-01',
  ),
  'KQ-VVIP-01': TableInfo(
    name: 'Meja VVIP',
    type: 'VVIP',
    code: 'KQ-VVIP-01',
  ),
};

class KingQueenApp extends StatelessWidget {
  const KingQueenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'King&Queen',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: brown),
        appBarTheme: const AppBarTheme(
          backgroundColor: brown,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// =====================================================
// HALAMAN AWAL DAN SCANNER QR
// =====================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TableInfo? meja;

  Future<void> scanQR() async {
    final hasil = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (scannerContext) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Meja'),
            backgroundColor: brown,
            foregroundColor: Colors.white,
          ),
          body: MobileScanner(
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;

              final value = capture.barcodes.first.rawValue;

              if (value == null || value.trim().isEmpty) return;

              Navigator.of(scannerContext).pop(value);
            },
          ),
        ),
      ),
    );

    if (!mounted || hasil == null) return;

    final kode = hasil.trim().toUpperCase();
    final mejaDitemukan = daftarMeja[kode];

    if (mejaDitemukan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR tidak dikenal: $hasil'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => meja = mejaDitemukan);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terhubung ke ${mejaDitemukan.name}'),
        backgroundColor: brown,
      ),
    );

    if (!mounted) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MenuPage(meja: mejaDitemukan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.coffee, color: gold, size: 27),
            SizedBox(width: 10),
            Text(
              'King&Queen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Login Admin / Kasir',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StaffLoginPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 750;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 36 : 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(desktop ? 38 : 25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3E2723),
                              Color(0xFF795548),
                              Color(0xFF9A7355),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: brown.withValues(alpha: 0.20),
                              blurRadius: 20,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -12,
                              bottom: -20,
                              child: Icon(
                                Icons.coffee,
                                size: desktop ? 180 : 130,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: gold.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: const Text(
                                    'PREMIUM CAFE EXPERIENCE',
                                    style: TextStyle(
                                      color: gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  'KING&QUEEN',
                                  style: TextStyle(
                                    color: gold,
                                    fontSize: desktop ? 17 : 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Nikmati Rasa\nIstimewa.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: desktop ? 42 : 34,
                                    height: 1.12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Temukan minuman dan camilan favoritmu\n'
                                  'dalam pengalaman pemesanan yang mudah.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    height: 1.5,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 23),
                                FilledButton.icon(
                                  onPressed: scanQR,
                                  icon: const Icon(Icons.qr_code_scanner),
                                  label: const Text(
                                    'Mulai Pesan Sekarang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: gold,
                                    foregroundColor: brown,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      if (meja != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 22),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F5E9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Meja berhasil terhubung',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text('${meja!.name} • ${meja!.type}'),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: scanQR,
                                child: const Text('Scan Ulang'),
                              ),
                            ],
                          ),
                        ),

                      const Text(
                        'Pesan dengan Mudah',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Nikmati pengalaman memesan tanpa antre.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 17),

                      GridView.count(
                        crossAxisCount: desktop ? 3 : 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: desktop ? 2.3 : 4.0,
                        children: const [
                          _HomeStepCard(
                            nomor: '01',
                            ikon: Icons.qr_code_scanner,
                            judul: 'Scan QR Meja',
                            deskripsi: 'Pindai kode QR di meja kamu.',
                          ),
                          _HomeStepCard(
                            nomor: '02',
                            ikon: Icons.restaurant_menu,
                            judul: 'Pilih Menu',
                            deskripsi: 'Pilih makanan dan minuman favorit.',
                          ),
                          _HomeStepCard(
                            nomor: '03',
                            ikon: Icons.receipt_long,
                            judul: 'Kirim Pesanan',
                            deskripsi: 'Pesanan diterima langsung oleh kasir.',
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE9DED1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5E9D9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.qr_code_2,
                                color: brown,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 13),
                            const Text(
                              'Siap Menikmati Favoritmu?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: brown,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              meja == null
                                  ? 'Scan QR Code pada meja untuk mulai memesan.'
                                  : 'Kamu terhubung dengan ${meja!.name}.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 17),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: scanQR,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('SCAN QR MEJA'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: brown,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.coffee, color: gold, size: 25),
                            SizedBox(height: 7),
                            Text(
                              'KING&QUEEN',
                              style: TextStyle(
                                color: brown,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Nikmati rasa istimewa di setiap pesanan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Pelanggan tidak perlu login untuk memesan.',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeStepCard extends StatelessWidget {
  final String nomor;
  final IconData ikon;
  final String judul;
  final String deskripsi;

  const _HomeStepCard({
    required this.nomor,
    required this.ikon,
    required this.judul,
    required this.deskripsi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9DED1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E9D9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(ikon, color: brown, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$nomor • $judul',
                  style: const TextStyle(
                    color: brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deskripsi,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MODEL DATA MENU FIRESTORE
// =====================================================

class MenuItem {
  final String nama;
  final String deskripsi;
  final int harga;
  final String kategori;
  final String fotoUrl;
  final bool tersedia;
  final IconData ikon;

  const MenuItem({
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    required this.fotoUrl,
    required this.tersedia,
    required this.ikon,
  });

  factory MenuItem.dariFirestore(
    Map<String, dynamic> data,
  ) {
    final kategori = (data['kategori'] ?? 'Lainnya').toString();

    IconData ikon;

    switch (kategori) {
      case 'Minuman':
        ikon = Icons.local_cafe;
        break;
      case 'Makanan':
        ikon = Icons.restaurant;
        break;
      default:
        ikon = Icons.fastfood;
    }

    return MenuItem(
      nama: (data['nama'] ?? 'Tanpa Nama').toString(),
      deskripsi: (data['deskripsi'] ?? '').toString(),
      harga: (data['harga'] as num?)?.toInt() ?? 0,
      kategori: kategori,
      fotoUrl: (data['fotoUrl'] ?? '').toString(),
      tersedia: data['tersedia'] != false,
      ikon: ikon,
    );
  }
}

// =====================================================
// HALAMAN MENU PELANGGAN
// =====================================================

class MenuPage extends StatefulWidget {
  final TableInfo meja;

  const MenuPage({
    super.key,
    required this.meja,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String kategoriAktif = 'Semua';

  final Map<String, int> keranjang = {};
  final Map<String, String> catatan = {};

  bool _sedangMengirim = false;

  // Data menu yang berasal dari Firestore.
  List<MenuItem> daftarMenu = [];

  final List<String> kategori = [
    'Semua',
    'Makanan',
    'Minuman',
    'Lainnya',
  ];

  String rupiah(int nilai) {
    return 'Rp${nilai.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    )}';
  }

  List<MenuItem> get menuTampil {
    final menuTersedia = daftarMenu
        .where((menu) => menu.tersedia)
        .toList();

    if (kategoriAktif == 'Semua') {
      return menuTersedia;
    }

    return menuTersedia
        .where((menu) => menu.kategori == kategoriAktif)
        .toList();
  }

  int get jumlahItem {
    return keranjang.values.fold(
      0,
      (total, jumlah) => total + jumlah,
    );
  }

  int get totalHarga {
    int total = 0;

    for (final menu in daftarMenu) {
      total += menu.harga * (keranjang[menu.nama] ?? 0);
    }

    return total;
  }

  void ubahJumlah(MenuItem menu, int perubahan) {
    setState(() {
      final jumlahBaru =
          (keranjang[menu.nama] ?? 0) + perubahan;

      if (jumlahBaru <= 0) {
        keranjang.remove(menu.nama);
        catatan.remove(menu.nama);
      } else {
        keranjang[menu.nama] = jumlahBaru;
      }
    });
  }

  Future<void> bukaCatatan(MenuItem menu) async {
    final controller = TextEditingController(
      text: catatan[menu.nama] ?? '',
    );

    final hasil = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Catatan ${menu.nama}'),
        content: TextField(
          controller: controller,
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: 'Contoh: gula 50%, es sedikit',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                controller.text.trim(),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (hasil != null && mounted) {
      setState(() {
        if (hasil.isEmpty) {
          catatan.remove(menu.nama);
        } else {
          catatan[menu.nama] = hasil;
        }
      });
    }
  }

  // ===================================================
  // KERANJANG
  // ===================================================

  void tampilkanKeranjang() {
    if (keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong. Pilih menu dulu!'),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cream,
      builder: (sheetContext) => StatefulBuilder(
        builder: (contextSheet, refreshSheet) {
          final menuKeranjang = daftarMenu.where(
            (menu) => (keranjang[menu.nama] ?? 0) > 0,
          ).toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keranjang Belanja 🛒',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.meja.name} • ${widget.meja.type}',
                    ),
                    const Divider(height: 25),

                    ...menuKeranjang.map((menu) {
                      final jumlah = keranjang[menu.nama] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        menu.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${rupiah(menu.harga)} × $jumlah',
                                      ),
                                      if (catatan[menu.nama] != null)
                                        Text(
                                          'Catatan: ${catatan[menu.nama]}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: brown,
                                          ),
                                        ),
                                      if (!menu.tersedia)
                                        const Text(
                                          'Menu tidak tersedia',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  rupiah(menu.harga * jumlah),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    await bukaCatatan(menu);
                                    refreshSheet(() {});
                                  },
                                  icon: const Icon(Icons.edit_note),
                                  label: const Text('Catatan'),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    ubahJumlah(menu, -1);
                                    refreshSheet(() {});
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                  ),
                                ),
                                Text('$jumlah'),
                                IconButton(
                                  onPressed: () {
                                    ubahJumlah(menu, 1);
                                    refreshSheet(() {});
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    }),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          rupiah(totalHarga),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          konfirmasiPesanan();
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Lanjut Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===================================================
  // CHECKOUT DAN SIMPAN PESANAN KE FIRESTORE
  // ===================================================

  Future<void> konfirmasiPesanan() async {
    if (keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
        ),
      );
      return;
    }

    if (_sedangMengirim) return;

    // Periksa apakah menu dalam keranjang masih tersedia.
    final menuTidakValid = keranjang.keys.where((nama) {
      final cocok = daftarMenu.where(
        (menu) => menu.nama == nama,
      );

      return cocok.isEmpty || !cocok.first.tersedia;
    }).toList();

    if (menuTidakValid.isNotEmpty) {
      setState(() {
        for (final nama in menuTidakValid) {
          keranjang.remove(nama);
          catatan.remove(nama);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ada menu yang sudah tidak tersedia atau dihapus admin. '
            'Silakan periksa kembali keranjang.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String metodePembayaran = 'Cash';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, refreshDialog) {
            return AlertDialog(
              title: const Text('Konfirmasi Pesanan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.meja.name} • ${widget.meja.type}',
                    ),
                    const Divider(height: 24),

                    ...daftarMenu
                        .where(
                          (menu) =>
                              (keranjang[menu.nama] ?? 0) > 0,
                        )
                        .map((menu) {
                      final jumlah = keranjang[menu.nama]!;
                      final catatanMenu =
                          catatan[menu.nama] ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${menu.nama} × $jumlah',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (catatanMenu.isNotEmpty)
                              Text(
                                'Catatan: $catatanMenu',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            Text(
                              rupiah(menu.harga * jumlah),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 24),

                    const Text(
                      'Total pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      rupiah(totalHarga),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Pilih metode pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: metodePembayaran,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Cash',
                          child: Text('Cash / Tunai'),
                        ),
                        DropdownMenuItem(
                          value: 'QRIS',
                          child: Text('QRIS'),
                        ),
                        DropdownMenuItem(
                          value: 'Bank',
                          child: Text('Transfer Bank'),
                        ),
                      ],
                      onChanged: _sedangMengirim
                          ? null
                          : (value) {
                              if (value != null) {
                                refreshDialog(() {
                                  metodePembayaran = value;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Catatan: pemilihan metode ini belum '
                      'memproses pembayaran secara otomatis. '
                      'Pembayaran perlu diverifikasi oleh kasir.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: _sedangMengirim
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Kembali'),
                ),

                FilledButton(
                  onPressed: _sedangMengirim
                      ? null
                      : () async {
                          setState(() {
                            _sedangMengirim = true;
                          });

                          refreshDialog(() {});

                          try {
                            // 1. Identitas pelanggan anonim.
                            final customer = await AuthService()
                                .ensureAnonymousCustomer();

                            // 2. Siapkan item pesanan.
                            final daftarItem = daftarMenu
                                .where(
                                  (menu) =>
                                      (keranjang[menu.nama] ?? 0) > 0,
                                )
                                .map((menu) {
                              return {
                                'nama': menu.nama,
                                'harga': menu.harga,
                                'jumlah': keranjang[menu.nama]!,
                                'catatan': catatan[menu.nama] ?? '',
                              };
                            }).toList();

                            final totalPesanan = totalHarga;

                            // 3. Buat referensi pesanan.
                            final orderRef =
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc();

                            // 4. Simpan pesanan.
                            await orderRef.set({
                              'nomorPesanan': orderRef.id,
                              'customerUid': customer.uid,
                              'kodeMeja': widget.meja.code,
                              'namaMeja': widget.meja.name,
                              'meja': widget.meja.name,
                              'tipeMeja': widget.meja.type,
                              'items': daftarItem,
                              'total': totalPesanan,
                              'metodePembayaran': metodePembayaran,
                              'statusPembayaran': 'belum_dibayar',
                              'status': 'menunggu',
                              'createdAt':
                                  FieldValue.serverTimestamp(),
                              'updatedAt':
                                  FieldValue.serverTimestamp(),
                            });

                            if (!mounted) return;

                            // ignore: use_build_context_synchronously
                            Navigator.pop(dialogContext);

                            // 5. Kosongkan keranjang.
                            setState(() {
                              keranjang.clear();
                              catatan.clear();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Pesanan berhasil dikirim! '
                                  'Nomor: ${orderRef.id.substring(0, 6)}',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } on FirebaseException catch (e) {
                            debugPrint(
                              'FIRESTORE ERROR: ${e.code}',
                            );
                            debugPrint(
                              'FIRESTORE MESSAGE: ${e.message}',
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menyimpan pesanan: '
                                  '${e.message ?? e.code}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } catch (e) {
                            debugPrint('ORDER ERROR: $e');

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Terjadi kesalahan: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _sedangMengirim = false;
                              });
                            }
                          }
                        },
                  child: _sedangMengirim
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kirim Pesanan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===================================================
  // TAMPILAN FOTO MENU
  // ===================================================

  Widget tampilkanFoto(MenuItem menu) {
    if (menu.fotoUrl.trim().isEmpty) {
      return Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF3E5D5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          menu.ikon,
          size: 40,
          color: brown,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        menu.fotoUrl,
        width: 100,
        height: 110,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Container(
            width: 100,
            height: 110,
            color: const Color(0xFFF3E5D5),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: brown,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5D5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              menu.ikon,
              size: 40,
              color: brown,
            ),
          );
        },
      ),
    );
  }

  // ===================================================
  // KARTU MENU
  // ===================================================

  Widget kartuMenu(MenuItem menu) {
    final jumlah = keranjang[menu.nama] ?? 0;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tampilkanFoto(menu),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8B8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      menu.kategori,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    menu.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    menu.deskripsi.isEmpty
                        ? 'Menu pilihan King&Queen'
                        : menu.deskripsi,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    rupiah(menu.harga),
                    style: const TextStyle(
                      color: brown,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (jumlah > 0) ...[
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => ubahJumlah(menu, -1),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                          ),
                        ),
                        Text('$jumlah'),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => ubahJumlah(menu, 1),
                          icon: const Icon(
                            Icons.add_circle_outline,
                          ),
                        ),
                      ] else
                        FilledButton.tonalIcon(
                          onPressed: () => ubahJumlah(menu, 1),
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                          ),
                          label: const Text('Tambah'),
                        ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Tambah catatan',
                        onPressed: () async {
                          if (jumlah == 0) {
                            ubahJumlah(menu, 1);
                          }

                          await bukaCatatan(menu);
                        },
                        icon: const Icon(Icons.edit_note),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // TAMPILAN MENU DENGAN STREAM FIRESTORE
  // ===================================================

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('menus')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('King&Queen Menu'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal mengambil menu dari Firebase.\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('King&Queen Menu'),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: brown,
              ),
            ),
          );
        }

        // Ambil data terbaru dari koleksi menus.
        daftarMenu = (snapshot.data?.docs ?? [])
            .map((doc) => MenuItem.dariFirestore(doc.data()))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('King&Queen Menu'),
            actions: [
              IconButton(
                tooltip: 'Keranjang belanja',
                onPressed: tampilkanKeranjang,
                icon: Badge(
                  label: Text('$jumlahItem'),
                  isLabelVisible: jumlahItem > 0,
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    18,
                    16,
                    16,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            brown,
                            Color(0xFF795548),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KING&QUEEN',
                            style: TextStyle(
                              color: gold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Temukan Favoritmu ✨',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Nikmati rasa istimewa di setiap pesanan.',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF0E2D0),
                          child: Icon(
                            Icons.table_restaurant,
                            color: brown,
                          ),
                        ),
                        title: Text(
                          widget.meja.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Tipe meja ${widget.meja.type}',
                        ),
                        trailing: const Icon(
                          Icons.verified,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Pilih Kategori',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: kategori.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(item),
                              selected: kategoriAktif == item,
                              selectedColor: gold,
                              onSelected: (_) {
                                setState(() {
                                  kategoriAktif = item;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Menu Pilihan Kami ☕',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (daftarMenu.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 45),
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 55,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada menu tersedia.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: brown,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Silakan hubungi admin King&Queen.',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (menuTampil.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 45),
                        child: Center(
                          child: Text(
                            'Tidak ada menu tersedia pada kategori ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      )
                    else
                      ...menuTampil.map(kartuMenu),
                  ],
                ),
              ),

              if (jumlahItem > 0)
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$jumlahItem item dipilih'),
                              Text(
                                rupiah(totalHarga),
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: brown,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: tampilkanKeranjang,
                          style: FilledButton.styleFrom(
                            backgroundColor: brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(15),
                          ),
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Keranjang'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}