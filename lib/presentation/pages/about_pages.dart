import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/responsive_center_layout.dart';
import '../../core/constants/app_constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: ResponsiveCenterLayout(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final maxWidth = isWide ? 700.0 : constraints.maxWidth;
            final horizontal = isWide ? (constraints.maxWidth - maxWidth) / 2 : 5.w;

            // Flexible logo sizing
            final shortest = MediaQuery.of(context).size.shortestSide;
            final logoSize = (shortest * 0.25).clamp(120.0, 240.0);

            final members = const [
              ['24111814081', 'Farouq Gusmo Abdillah'],
              ['24111814028', 'Bernaldi Atma Tanjung S'],
              ['24111814090', 'Bagus Adibrata'],
              ['24111814010', 'Dita Titania'],
              ['24111814016', 'Berliana Kurnia Dewi'],
              ['24111814135', 'Diky Ari Setiyawan'],
              ["24111814113", "Fakhrur Rohman Sa'id"],
            ];

            return Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 5.h, horizontal, 5.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo Aplikasi (flexible)
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(logoSize * 0.6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: EdgeInsets.all(logoSize * 0.06),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.asset('assets/images/logo.png'),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // Nama Aplikasi
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 5.h),

                        // Deskripsi
                        Text(
                          'AnimInfo adalah aplikasi penyedia informasi anime terlengkap yang menggunakan Jikan API. Dibuat untuk memenuhi tugas mata kuliah Pemrograman Mobile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 5.h),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        SizedBox(height: 2.h),

                        // Developer Info
                        Text(
                          'Developed by:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Kelompok 5',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Member list (kanan Nama, kiri NIM)
                        Column(
                          children: [
                            for (final pair in members)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 0.6.h, horizontal: 2.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pair[1], // NIM kiri
                                        style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        pair[0], // Nama kanan
                                        style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 4.h),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        SizedBox(height: 1.5.h),
                        Text(
                          '© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}