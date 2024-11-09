// lib/src/utils/ndef_helper.dart

import 'dart:typed_data';

class NDEFHelper {
  static Uint8List createNDEFMessage(String text) {
    // NDEF Message structure
    // [NDEF Record Header, Length, Type Length, Payload Length, Type, Payload]
    
    // Text record type "T"
    final type = [0x54]; // 'T' in ASCII
    
    // Language code "en" + text
    final language = [0x65, 0x6E]; // 'en' in ASCII
    final textBytes = Uint8List.fromList(text.codeUnits);
    final payload = [...language, ...textBytes];
    
    // Record header byte
    // | MB(1) | ME(1) | CF(1) | SR(1) | IL(1) | TNF(3) |
    // MB: Message Begin = 1
    // ME: Message End = 1
    // CF: Chunk Flag = 0
    // SR: Short Record = 1 (payload length < 256 bytes)
    // IL: ID Length present = 0
    // TNF: Type Name Format = 1 (NFC Forum Well Known Type)
    final header = 0xD1; // 11010001 in binary
    
    // Create the message
    final message = [
      header,
      type.length, // Type length
      payload.length, // Payload length
      ...type,
      ...payload,
    ];
    
    return Uint8List.fromList(message);
  }

  static Future<Uint8List> formatTextRecord(String text) async {
    try {
      return createNDEFMessage(text);
    } catch (e) {
      throw Exception('Failed to create NDEF message: $e');
    }
  }
}