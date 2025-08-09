// lib/core/utils/image_zipper.dart
import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';

class ZipRequest {
  final List<File> files;
  final String outPath;
  ZipRequest(this.files, this.outPath);
}

Future<File> zipImages(List<File> files, String outPath) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_zipIsolate, [receivePort.sendPort, files.map((f)=>f.path).toList(), outPath]);
  final result = await receivePort.first as String;
  return File(result);
}

void _zipIsolate(List<dynamic> args) {
  final SendPort sendPort = args[0] as SendPort;
  final List<String> paths = (args[1] as List).cast<String>();
  final String outPath = args[2] as String;
  final encoder = ZipFileEncoder();
  encoder.create(outPath);
  for (final p in paths) {
    final f = File(p);
    if (f.existsSync()) encoder.addFile(f);
  }
  encoder.close();
  sendPort.send(outPath);
}
