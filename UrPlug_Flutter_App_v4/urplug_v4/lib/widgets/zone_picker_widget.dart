import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/zone.dart';
import '../theme/app_colors.dart';

/// Cascading zone selector: Region → District → Division/Sub-county →
/// Parish/Village → Landmark (free text).
///
/// Used on both the consumer location setup screen and the provider
/// registration screen. Calls [onChanged] whenever the selection is
/// complete enough to form a valid [ZoneAddress].
class ZonePickerWidget extends StatefulWidget {
  final ZoneAddress? initial;
  final void Function(ZoneAddress? address) onChanged;
  final bool showLandmark;

  const ZonePickerWidget({
    super.key,
    this.initial,
    required this.onChanged,
    this.showLandmark = true,
  });

  @override
  State<ZonePickerWidget> createState() => _ZonePickerWidgetState();
}

class _ZonePickerWidgetState extends State<ZonePickerWidget> {
  final _landmarkCtrl = TextEditingController();

  String? _regionId;
  String? _districtId;
  String? _divisionId;
  String? _parishId;

  // Filtered zone lists
  List<Zone> get _regions =>
      MockData.zones.where((z) => z.level == ZoneLevel.region).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<Zone> get _districts => _regionId == null
      ? []
      : MockData.zones
            .where((z) =>
                z.level == ZoneLevel.district && z.parentId == _regionId)
            .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<Zone> get _divisions => _districtId == null
      ? []
      : MockData.zones
            .where((z) =>
                z.level == ZoneLevel.division && z.parentId == _districtId)
            .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<Zone> get _parishes => _divisionId == null
      ? []
      : MockData.zones
            .where((z) =>
                z.level == ZoneLevel.parish && z.parentId == _divisionId)
            .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _regionId   = init.regionId.isEmpty   ? null : init.regionId;
      _districtId = init.districtId.isEmpty ? null : init.districtId;
      _divisionId = init.divisionId.isEmpty ? null : init.divisionId;
      _parishId   = init.parishId.isEmpty   ? null : init.parishId;
      _landmarkCtrl.text = init.landmark ?? '';
    }
  }

  void _notify() {
    if (_regionId != null &&
        _districtId != null &&
        _divisionId != null &&
        _parishId != null) {
      widget.onChanged(ZoneAddress(
        regionId:   _regionId!,
        districtId: _districtId!,
        divisionId: _divisionId!,
        parishId:   _parishId!,
        landmark:   _landmarkCtrl.text.trim().isEmpty
                      ? null
                      : _landmarkCtrl.text.trim(),
      ));
    } else {
      widget.onChanged(null);
    }
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<Zone> items,
    required void Function(String?) onChanged,
    required bool enabled,
    IconData icon = Icons.place_outlined,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon,
              color: enabled ? AppColors.primaryGreen : Colors.grey),
          filled: true,
          fillColor: enabled
              ? null
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.any((z) => z.id == value) ? value : null,
            hint: Text(enabled
                ? 'Select $label'
                : 'Select ${_previousLabel(label)} first'),
            isExpanded: true,
            items: items
                .map((z) => DropdownMenuItem(
                      value: z.id,
                      child: Text(z.name, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }

  String _previousLabel(String label) {
    const map = {
      'District': 'Region',
      'Division / Sub-county': 'District',
      'Parish / Village': 'Division',
    };
    return map[label] ?? 'previous level';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Region ────────────────────────────────────────────────────
        _dropdown(
          label: 'Region',
          value: _regionId,
          items: _regions,
          enabled: true,
          icon: Icons.public_outlined,
          onChanged: (v) {
            setState(() {
              _regionId   = v;
              _districtId = null;
              _divisionId = null;
              _parishId   = null;
            });
            _notify();
          },
        ),

        // ── District ──────────────────────────────────────────────────
        _dropdown(
          label: 'District',
          value: _districtId,
          items: _districts,
          enabled: _regionId != null,
          icon: Icons.location_city_outlined,
          onChanged: (v) {
            setState(() {
              _districtId = v;
              _divisionId = null;
              _parishId   = null;
            });
            _notify();
          },
        ),

        // ── Division / Sub-county ─────────────────────────────────────
        _dropdown(
          label: 'Division / Sub-county',
          value: _divisionId,
          items: _divisions,
          enabled: _districtId != null,
          icon: Icons.place_outlined,
          onChanged: (v) {
            setState(() {
              _divisionId = v;
              _parishId   = null;
            });
            _notify();
          },
        ),

        // ── Parish / Village ──────────────────────────────────────────
        _dropdown(
          label: 'Parish / Village',
          value: _parishId,
          items: _parishes,
          enabled: _divisionId != null,
          icon: Icons.where_to_vote_outlined,
          onChanged: (v) {
            setState(() => _parishId = v);
            _notify();
          },
        ),

        // ── Landmark ──────────────────────────────────────────────────
        if (widget.showLandmark)
          TextField(
            controller: _landmarkCtrl,
            enabled: _parishId != null,
            onChanged: (_) => _notify(),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Landmark (optional)',
              hintText: 'e.g. Near Wandegeya Market, Opposite Total Ntinda',
              prefixIcon: const Icon(Icons.flag_outlined),
              helperText:
                  'A nearby well-known place helps consumers find you faster.',
            ),
          ),

        // ── Progress indicator ────────────────────────────────────────
        const SizedBox(height: 16),
        _ZoneProgress(
          regionId:   _regionId,
          districtId: _districtId,
          divisionId: _divisionId,
          parishId:   _parishId,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _landmarkCtrl.dispose();
    super.dispose();
  }
}

class _ZoneProgress extends StatelessWidget {
  final String? regionId, districtId, divisionId, parishId;
  const _ZoneProgress({
    this.regionId, this.districtId, this.divisionId, this.parishId,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Region',             regionId != null),
      ('District',           districtId != null),
      ('Division',           divisionId != null),
      ('Parish / Village',   parishId != null),
    ];
    return Row(
      children: steps.map((s) {
        final done = s.$2;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.primaryGreen
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.15),
                ),
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  s.$1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight:
                        done ? FontWeight.w700 : FontWeight.w400,
                    color: done
                        ? AppColors.primaryGreen
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
