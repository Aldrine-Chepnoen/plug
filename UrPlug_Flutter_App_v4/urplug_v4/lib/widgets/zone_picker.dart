import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/zone.dart';
import '../theme/app_colors.dart';

/// Hierarchical zone picker: Region → District → Division → Parish → Landmark.
/// Returns a [ZoneAddress] when all 4 admin levels are selected.
/// Used in both consumer setup and provider registration.
class ZonePicker extends StatefulWidget {
  /// Initial value — pre-fills dropdowns if not null.
  final ZoneAddress? initialValue;

  /// Called whenever a complete ZoneAddress is selected (all 4 levels filled).
  final ValueChanged<ZoneAddress> onChanged;

  /// Whether to show the landmark text field.
  final bool showLandmark;

  const ZonePicker({
    super.key,
    required this.onChanged,
    this.initialValue,
    this.showLandmark = true,
  });

  @override
  State<ZonePicker> createState() => _ZonePickerState();
}

class _ZonePickerState extends State<ZonePicker> {
  Zone? _region;
  Zone? _district;
  Zone? _division;
  Zone? _parish;
  final _landmarkController = TextEditingController();

  // Helpers ──────────────────────────────────────────────────────────────────
  List<Zone> get _regions =>
      MockData.zones.where((z) => z.level == ZoneLevel.region).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<Zone> _districtsFor(Zone region) =>
      MockData.zones
          .where((z) => z.level == ZoneLevel.district && z.parentId == region.id)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<Zone> _divisionsFor(Zone district) =>
      MockData.zones
          .where((z) => z.level == ZoneLevel.division && z.parentId == district.id)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<Zone> _parishesFor(Zone division) =>
      MockData.zones
          .where((z) => z.level == ZoneLevel.parish && z.parentId == division.id)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  @override
  void initState() {
    super.initState();
    final init = widget.initialValue;
    if (init != null) {
      _region   = _regions.where((z) => z.id == init.regionId).firstOrNull;
      if (_region != null) {
        _district = _districtsFor(_region!).where((z) => z.id == init.districtId).firstOrNull;
        if (_district != null) {
          _division = _divisionsFor(_district!).where((z) => z.id == init.divisionId).firstOrNull;
          if (_division != null) {
            _parish = _parishesFor(_division!).where((z) => z.id == init.parishId).firstOrNull;
          }
        }
      }
      _landmarkController.text = init.landmark ?? '';
    }
  }

  void _notify() {
    if (_region == null || _district == null ||
        _division == null || _parish == null) return;
    widget.onChanged(ZoneAddress(
      regionId:   _region!.id,
      districtId: _district!.id,
      divisionId: _division!.id,
      parishId:   _parish!.id,
      landmark:   _landmarkController.text.trim().isEmpty
                  ? null
                  : _landmarkController.text.trim(),
    ));
  }

  Widget _dropdown<T extends Zone?>({
    required String label,
    required String hint,
    required T? value,
    required List<Zone> items,
    required bool enabled,
    required ValueChanged<Zone?> onChanged,
    IconData icon = Icons.location_on_outlined,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13.5)),
        const SizedBox(height: 6),
        DropdownButtonFormField<Zone>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13.5)),
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            enabled: enabled,
            filled: true,
            fillColor: enabled
                ? null
                : Theme.of(context).disabledColor.withValues(alpha: 0.05),
          ),
          items: items
              .map((z) => DropdownMenuItem<Zone>(
                    value: z,
                    child: Text(z.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        _ProgressRow(
          regionDone:   _region   != null,
          districtDone: _district != null,
          divisionDone: _division != null,
          parishDone:   _parish   != null,
        ),
        const SizedBox(height: 18),

        // Region
        _dropdown<Zone?>(
          label: 'Region',
          hint: 'Select your region',
          value: _region,
          items: _regions,
          enabled: true,
          icon: Icons.public_outlined,
          onChanged: (v) => setState(() {
            _region   = v;
            _district = null;
            _division = null;
            _parish   = null;
          }),
        ),

        // District
        _dropdown<Zone?>(
          label: 'District',
          hint: _region == null ? 'Select region first' : 'Select your district',
          value: _district,
          items: _region != null ? _districtsFor(_region!) : [],
          enabled: _region != null,
          icon: Icons.location_city_outlined,
          onChanged: (v) => setState(() {
            _district = v;
            _division = null;
            _parish   = null;
          }),
        ),

        // Division / Sub-county
        _dropdown<Zone?>(
          label: 'Division / Sub-county / Municipality',
          hint: _district == null ? 'Select district first' : 'Select your division',
          value: _division,
          items: _district != null ? _divisionsFor(_district!) : [],
          enabled: _district != null,
          icon: Icons.place_outlined,
          onChanged: (v) => setState(() {
            _division = v;
            _parish   = null;
          }),
        ),

        // Parish / Village
        _dropdown<Zone?>(
          label: 'Parish / Village',
          hint: _division == null ? 'Select division first' : 'Select your parish',
          value: _parish,
          items: _division != null ? _parishesFor(_division!) : [],
          enabled: _division != null,
          icon: Icons.where_to_vote_outlined,
          onChanged: (v) {
            setState(() => _parish = v);
            _notify();
          },
        ),

        // Landmark (optional)
        if (widget.showLandmark) ...[
          const Text('Landmark (optional)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          const SizedBox(height: 6),
          TextField(
            controller: _landmarkController,
            onChanged: (_) => _notify(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.storefront_outlined, size: 18),
              hintText: 'e.g. Opposite Shell Ntinda, Near Wandegeya Market',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Helps customers find you. Use a well-known nearby reference point.',
            style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    super.dispose();
  }
}

// ── Progress row ───────────────────────────────────────────────────────────
class _ProgressRow extends StatelessWidget {
  final bool regionDone, districtDone, divisionDone, parishDone;
  const _ProgressRow({
    required this.regionDone,
    required this.districtDone,
    required this.divisionDone,
    required this.parishDone,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Region', regionDone),
      ('District', districtDone),
      ('Division', divisionDone),
      ('Parish', parishDone),
    ];
    return Row(
      children: steps.map((s) {
        final done = s.$2;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.primaryGreen
                        : AppColors.primaryGreen.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(s.$1,
                    style: TextStyle(
                        fontSize: 10,
                        color: done
                            ? AppColors.primaryGreenDark
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                        fontWeight: done ? FontWeight.w700 : FontWeight.w400)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
