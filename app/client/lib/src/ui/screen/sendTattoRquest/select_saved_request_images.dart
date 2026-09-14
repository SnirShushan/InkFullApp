import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/folderImage.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:path_provider/path_provider.dart';

class SelectSavedRequestImages extends StatefulWidget {
  final int maxCount;

  const SelectSavedRequestImages({super.key, required this.maxCount});

  @override
  State<SelectSavedRequestImages> createState() =>
      _SelectSavedRequestImagesState();
}

class _SelectSavedRequestImagesState extends State<SelectSavedRequestImages> {
  final UserController _userController = Get.put(UserController());
  final List<String> _selected = [];
  List<String> _images = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  String _folderUid() {
    final fromUser = _userController.firebaseId.value.trim();
    if (fromUser.isNotEmpty && fromUser != "null") return fromUser;
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  List<String> _urlsFromField(String raw) {
    var value = raw.trim();
    if (value.isEmpty || value == "null") return [];
    if (value.startsWith('[') && value.endsWith(']')) {
      value = value.substring(1, value.length - 1);
      return value
          .split(',')
          .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ""))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [value];
  }

  Future<void> _loadImages() async {
    final uid = _folderUid();
    if (uid.isEmpty) {
      setState(() {
        _images = [];
        _loading = false;
      });
      return;
    }

    try {
      final folders = await FirebaseFirestore.instance
          .collection('folders')
          .where('uid', isEqualTo: uid)
          .get();
      final fids = folders.docs
          .map((doc) => (doc.data()['fid'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();

      final urls = <String>{};
      if (fids.isNotEmpty) {
        final fidList = fids.toList();
        for (var i = 0; i < fidList.length; i += 10) {
          final chunk = fidList.sublist(i, min(i + 10, fidList.length));
          final snap = await FirebaseFirestore.instance
              .collection('foldersImages')
              .where('fid', whereIn: chunk)
              .get();
          for (final doc in snap.docs) {
            final image = FolderImage.fromJson(doc.data());
            urls.addAll(_urlsFromField(image.imageUrl));
          }
        }
      }

      if (mounted) {
        setState(() {
          _images = urls.toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _images = [];
          _loading = false;
        });
      }
    }
  }

  void _toggle(String url) {
    setState(() {
      if (_selected.contains(url)) {
        _selected.remove(url);
        return;
      }
      if (_selected.length >= widget.maxCount) {
        displayMessageIcon(
            message: 'ניתן לבחור עד ${widget.maxCount} תמונות.',
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);
        return;
      }
      _selected.add(url);
    });
  }

  Future<void> _finish() async {
    if (_selected.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final files = <File>[];
      final dir = await getTemporaryDirectory();
      final dio = Dio();
      for (var i = 0; i < _selected.length; i++) {
        final url = WebService.resolveImageUrl(_selected[i]);
        final path =
            '${dir.path}/request_saved_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        await dio.download(url, path);
        final file = File(path);
        if (await file.exists() && await file.length() > 0) {
          files.add(file);
        }
      }
      if (!mounted) return;
      if (files.isEmpty) {
        displayMessageIcon(
            message: 'לא ניתן לטעון את התמונות שנבחרו',
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);
        setState(() => _saving = false);
        return;
      }
      Navigator.of(context).pop(files);
    } catch (_) {
      if (mounted) {
        displayMessageIcon(
            message: 'לא ניתן לטעון את התמונות שנבחרו',
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: const AppBarBackButtonWidget(
        title: 'תמונות שמורות',
        titleColor: titleTextColor,
        iconColor: titleTextColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(AppAssets.notFound, width: 140),
                            const SizedBox(height: 16),
                            const Text(
                              'אין תמונות שמורות',
                              style: TextStyle(
                                color: titleTextWhiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          final url = _images[index];
                          final resolved = WebService.resolveImageUrl(url);
                          final isSelected = _selected.contains(url);
                          return GestureDetector(
                            onTap: () => _toggle(url),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ColorFiltered(
                                    colorFilter: isSelected
                                        ? ColorFilter.mode(
                                            Colors.black.withOpacity(0.45),
                                            BlendMode.srcATop)
                                        : const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.multiply),
                                    child: CachedNetworkImage(
                                      imageUrl: resolved,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, _, __) =>
                                          Image.asset(
                                        "assets/images/placeholder.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: SvgPicture.asset(
                                      isSelected
                                          ? AppAssets.checkedCircleFilledIcon
                                          : AppAssets.circle,
                                      color: titleTextWhiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: InkWell(
                onTap: _selected.isEmpty || _saving ? null : _finish,
                child: Container(
                  width: size.width,
                  height: size.height * 0.07,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: _selected.isNotEmpty
                          ? [
                              linearGradieantColor1,
                              linearGradieantColor2,
                              linearGradieantColor3,
                            ]
                          : [
                              lineargrayGradieantColor1,
                              lineargrayGradieantColor2,
                              lineargrayGradieantColor3,
                            ],
                      stops: const [0.0, 0.001, 0.8937],
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: kWhite)
                      : Text(
                          "סיים",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: _selected.isNotEmpty
                                    ? kWhite
                                    : defaultGrey,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
