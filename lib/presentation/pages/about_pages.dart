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
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5.h),
              // Logo Aplikasi
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(15.w),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: 15.w,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                  fontSize: 12.sp,
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
            ],
          ),
        ),
      ),
    );
  }
}