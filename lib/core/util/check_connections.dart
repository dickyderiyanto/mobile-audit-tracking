import 'dart:io';

class CheckConnections {
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('audit.jessindo.net');
      final connected = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      print("🌐 Internet status: $connected");
      return connected;
    } catch (e) {
      print("🚫 Tidak ada koneksi internet: $e");
      return false;
    }
  }
}
