import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  XFile? imagemCortada;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // Função para carregar e cortar a imagem após o initState
  void _loadImage() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _cropAndSaveImage(widget.picture, 448);
    });
  }

  // Função para chamar a função cropImage e cortar a imagem
  Future<void> _cropAndSaveImage(XFile? imageToCrop, double size) async {
    if (imageToCrop != null) {
      final XFile? croppedImage = await cropImage(imageToCrop, size);
      if (croppedImage != null) {
        setState(() {
          imagemCortada = croppedImage;
        });
      }
    }
  }

  // Função para cortar a imagem
  Future<XFile?> cropImage(XFile? sourceImage, double size) async {
    if (sourceImage == null) {
      return null;
    }
    // Carregar a imagem usando o pacote image_picker
    final File file = File(sourceImage.path);
    // Ler a imagem usando o pacote image
    img.Image? image = img.decodeImage(file.readAsBytesSync());

    if (image == null) {
      return null;
    }
    // Calcular as coordenadas para recortar um quadrado central
    final int x = (image.width - size) ~/ 2;
    final int y = (image.height - size) ~/ 2;
    // Recortar a imagem
    image = img.copyCrop(image,
        x: x, y: y, width: size.toInt(), height: size.toInt());
    // Salvar a imagem recortada em um novo arquivo
    final File croppedFile = File('${sourceImage.path}_cropped.jpg');
    croppedFile.writeAsBytesSync(img.encodeJpg(image));
    return XFile(croppedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Image.file(File(widget.picture.path), fit: BoxFit.cover, width: 250),
          // const SizedBox(height: 24),
          Text(imagemCortada!.name),
          if (imagemCortada != null) Image.file(File(imagemCortada!.path)),
        ]),
      ),
    );
  }
}
