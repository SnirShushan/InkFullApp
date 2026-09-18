import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

class IsraelAddress {
  final String label;
  final double lat;
  final double lng;
  final String city;
  final String placeId;

  const IsraelAddress({
    required this.label,
    required this.lat,
    required this.lng,
    required this.city,
    required this.placeId,
  });
}

Future<List<IsraelAddress>> searchIsraelAddresses(String query) async {
  final q = query.trim();
  if (q.length < 2) return [];
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'q': q,
    'countrycodes': 'il',
    'format': 'jsonv2',
    'addressdetails': '1',
    'accept-language': 'he',
    'limit': '8',
  });
  try {
    final dio = Dio(BaseOptions(
      connectTimeout: 8000,
      receiveTimeout: 8000,
      headers: {
        'User-Agent': 'InkIsraelApp/1.0 (address-search)',
        'Accept-Language': 'he',
      },
    ));
    final res = await dio.getUri(uri);
    final decoded = res.data;
    if (decoded is! List) return [];
    final results = <IsraelAddress>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final parsed = _fromNominatim(item);
      if (parsed != null) results.add(parsed);
    }
    return results;
  } catch (_) {
    return [];
  }
}

IsraelAddress? _fromNominatim(Map item) {
  final lat = double.tryParse('${item['lat'] ?? ''}');
  final lng = double.tryParse('${item['lon'] ?? ''}');
  if (lat == null || lng == null) return null;
  final addr = item['address'] is Map
      ? Map<String, dynamic>.from(item['address'] as Map)
      : <String, dynamic>{};
  final city = (addr['city'] ??
          addr['town'] ??
          addr['village'] ??
          addr['municipality'] ??
          addr['county'] ??
          '')
      .toString()
      .trim();
  final road = (addr['road'] ??
          addr['pedestrian'] ??
          addr['residential'] ??
          addr['suburb'] ??
          '')
      .toString()
      .trim();
  final number = (addr['house_number'] ?? '').toString().trim();
  String label;
  if (road.isNotEmpty) {
    final street = [road, number].where((e) => e.isNotEmpty).join(' ');
    label = city.isNotEmpty ? '$street, $city' : street;
  } else {
    label = (item['display_name'] ?? '').toString().trim();
  }
  if (label.isEmpty) return null;
  return IsraelAddress(
    label: label,
    lat: lat,
    lng: lng,
    city: city,
    placeId: '${item['place_id'] ?? ''}',
  );
}

class IsraelAddressField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final bool applyToWebService;
  final bool showCheckWhenFilled;
  final ValueChanged<IsraelAddress>? onSelected;
  final ValueChanged<String>? onTextChanged;

  const IsraelAddressField({
    super.key,
    required this.controller,
    this.hintText,
    this.style,
    this.hintStyle,
    this.decoration,
    this.applyToWebService = true,
    this.showCheckWhenFilled = false,
    this.onSelected,
    this.onTextChanged,
  });

  @override
  State<IsraelAddressField> createState() => _IsraelAddressFieldState();
}

class _IsraelAddressFieldState extends State<IsraelAddressField> {
  Timer? _debounce;
  int _searchSeq = 0;
  bool _loading = false;
  List<IsraelAddress> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onTextChanged?.call(value);
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(value));
  }

  Future<void> _search(String value) async {
    final seq = ++_searchSeq;
    setState(() => _loading = true);
    final results = await searchIsraelAddresses(value);
    if (!mounted || seq != _searchSeq) return;
    setState(() {
      _loading = false;
      _results = results;
    });
  }

  void _select(IsraelAddress address) {
    widget.controller.text = address.label;
    widget.controller.selection = TextSelection.collapsed(
      offset: address.label.length,
    );
    if (widget.applyToWebService) {
      WebService.address = address.label;
      WebService.lat = address.lat;
      WebService.lang = address.lng;
      WebService.cityName = address.city;
      WebService.placeId = address.placeId;
    }
    widget.onSelected?.call(address);
    widget.onTextChanged?.call(address.label);
    setState(() {
      _results = [];
      _loading = false;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.trim().isNotEmpty;
    final decoration = (widget.decoration ??
            InputDecoration(
              hintText: widget.hintText,
              hintStyle: widget.hintStyle ??
                  const TextStyle(color: hintTextColor),
              contentPadding: const EdgeInsets.all(8),
              filled: true,
              fillColor: socialoginbtn,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ))
        .copyWith(
      suffixIcon: widget.showCheckWhenFilled && filled
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(AppAssets.correct_transparentIcon),
            )
          : widget.decoration?.suffixIcon,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.search,
          style: widget.style ?? const TextStyle(color: kWhite),
          decoration: decoration,
          onChanged: _onChanged,
          onFieldSubmitted: (_) {
            if (_results.isNotEmpty) _select(_results.first);
          },
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: titleTextColor,
              backgroundColor: textEditingColor,
            ),
          ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: signInButtonColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: textEditingColor),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: textEditingColor),
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    item.label,
                    style: const TextStyle(
                      color: titleTextWhiteColor,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () => _select(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
