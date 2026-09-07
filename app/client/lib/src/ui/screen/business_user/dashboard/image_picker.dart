import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:photo_manager/photo_manager.dart';

// Main usage example
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AssetEntity> selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker Demo'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomImagePicker(maxImages: 3),
                ),
              );
              if (result != null) {
                setState(() {
                  selectedImages = result;
                });
              }
            },
            child: const Text('Pick Images (Max 3)'),
          ),
          const SizedBox(height: 20),
          Text('Selected: ${selectedImages.length} images'),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Uint8List?>(
                  future: selectedImages[index].thumbnailData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Image Picker Widget
class CustomImagePicker extends StatefulWidget {
  final int maxImages;

  const CustomImagePicker({Key? key, this.maxImages = 3}) : super(key: key);

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  List<AssetEntity> assets = [];
  List<AssetEntity> selectedAssets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    // final PermissionState permission = await PhotoManager.requestPermissionExtend();

    // if (permission.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> media = await albums[0].getAssetListRange(
          start: 0,
          end: 100,
        );
        setState(() {
          assets = media;
          isLoading = false;
        });
      }
    // } else {
    //   PhotoManager.openSetting();
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (selectedAssets.contains(asset)) {
        selectedAssets.remove(asset);
      } else {
        if (selectedAssets.length < widget.maxImages) {
          selectedAssets.add(asset);
        } else {
          displayMessageIcon(
              message: 'ניתן לבחור עד ${widget.maxImages} תמונות',

              color: errorColor,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.errorIcon);

        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(' בחירת תמונות ${selectedAssets.length}/${widget.maxImages}'),
        actions: [
          TextButton(
            onPressed: selectedAssets.isEmpty
                ? null
                : () {
              Navigator.pop(context, selectedAssets);
            },
            child: const Text(
              'סיים',
              // 'Done',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assets.isEmpty
          ? const Center(child: Text('No images found'))
          : GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          final isSelected = selectedAssets.contains(asset);
          final selectionIndex = selectedAssets.indexOf(asset) + 1;

          return GestureDetector(
            onTap: () => _toggleSelection(asset),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FutureBuilder<Uint8List?>(
                  future: asset.thumbnailData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                if (isSelected)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isSelected
                          ? Text(
                        '$selectionIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}