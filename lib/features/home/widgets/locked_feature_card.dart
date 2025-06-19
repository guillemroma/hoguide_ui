import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../services/auth_service.dart';
import '../../../common/widgets/dashboard_card.dart'; 

// --- El Modelo y el Enum ---
class ActionItem {
  final String title;
  final String description;
  final int currentCount;
  final int totalCount;
  ActionItem({required this.title, required this.description, this.currentCount = 0, this.totalCount = 0});
  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      title: json['title'] ?? 'Título no disponible',
      description: json['description'] ?? '',
      currentCount: json['current_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }
}

enum ActionState { locked, initial, loading, readyToClaim, success }

// --- WIDGET PRINCIPAL ---
class LockedFeatureCard extends StatefulWidget {
  final int userPoints;
  final String authToken;

  const LockedFeatureCard({super.key, required this.userPoints, required this.authToken});
  
  static const int requiredPoints = 14;

  @override
  State<LockedFeatureCard> createState() => _LockedFeatureCardState();
}

class _LockedFeatureCardState extends State<LockedFeatureCard> {
  late ActionState _currentState;
  ActionItem? _finalActionItem;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // CORRECCIÓN DEFINITIVA: Asigna el valor inicial directamente.
    // No llama a ningún método que lea _currentState.
    _currentState = (widget.userPoints >= LockedFeatureCard.requiredPoints)
        ? ActionState.initial
        : ActionState.locked;
  }

  @override
  void didUpdateWidget(LockedFeatureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // CORRECCIÓN DEFINITIVA: La lógica de actualización solo se llama aquí,
    // donde es seguro porque initState ya ha corrido.
    if (widget.userPoints != oldWidget.userPoints) {
      _updateStateBasedOnPoints();
    }
  }
  
  void _updateStateBasedOnPoints() {
    // Esta guarda previene que un cambio en puntos resetee un proceso ya iniciado.
    // Es seguro usarla aquí.
    if (_currentState == ActionState.loading || _currentState == ActionState.readyToClaim || _currentState == ActionState.success) {
      return;
    }
    setState(() {
      _currentState = (widget.userPoints >= LockedFeatureCard.requiredPoints)
          ? ActionState.initial
          : ActionState.locked;
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LÓGICA DE NEGOCIO QUE USA AUTHSERVICE ---

  Future<void> _initiateAndStartTimer() async {
    setState(() => _currentState = ActionState.loading);

    final bool success = await AuthService.generateActionItem(widget.authToken);

    if (!mounted) return;

    if (success) {
      _timer = Timer(const Duration(minutes: 5), () {
        if (mounted) setState(() => _currentState = ActionState.readyToClaim);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar la generación. Inténtalo de nuevo.')),
      );
      setState(() => _currentState = ActionState.initial);
    }
  }

  Future<void> _claimReward() async {
    setState(() => _currentState = ActionState.loading);
    
    final actionItem = await AuthService.fetchFirstActionItem(widget.authToken);

    if (!mounted) return;

    if (actionItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró un Action Item activo. Inténtalo más tarde.')),
      );
      setState(() => _currentState = ActionState.initial);
      return;
    }

    if (actionItem.description == 'in_progress') {
      _initiateAndStartTimer();
    } else {
      setState(() {
        _currentState = ActionState.success;
        _finalActionItem = actionItem;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case ActionState.locked:
        return _LockedView(userPoints: widget.userPoints, onGenerate: () {});
      case ActionState.initial:
        return _LockedView(userPoints: widget.userPoints, onGenerate: _initiateAndStartTimer);
      case ActionState.loading:
        return const _UnderConstructionView();
      case ActionState.readyToClaim:
        return _ReadyToClaimView(onClaim: _claimReward);
      case ActionState.success:
        return _finalActionItem != null
            ? _ActiveActionItemView(item: _finalActionItem!)
            : const Center(child: Text("Error al mostrar el item."));
    }
  }
}

// --- WIDGETS DE UI (SIN CAMBIOS) ---
class _LockedView extends StatelessWidget {
  final int userPoints;
  final VoidCallback onGenerate;
  const _LockedView({ required this.userPoints, required this.onGenerate });
  
  @override
  Widget build(BuildContext context) {
    final bool canGenerate = userPoints >= LockedFeatureCard.requiredPoints;
    final double progress = canGenerate ? 1.0 : (userPoints / LockedFeatureCard.requiredPoints).clamp(0.0, 1.0);
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(16.0),
      padding: EdgeInsets.zero,
      strokeWidth: 2.0,
      color: Theme.of(context).dividerColor,
      dashPattern: const [8, 4],
      child: DashboardCard(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        showShadow: false,
        onTap: canGenerate ? onGenerate : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.lock_outline, size: 32.0, color: Colors.indigo.shade400),
            const SizedBox(width: 20.0),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Action Items', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4.0),
              Text('Consigue ${LockedFeatureCard.requiredPoints} Hopoints y desbloquea tu plan personalizado.', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ])),
          ]),
          const SizedBox(height: 16.0),
          ClipRRect(borderRadius: BorderRadius.circular(10.0), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.7), color: Colors.deepPurple, minHeight: 10)),
          const SizedBox(height: 8.0),
          Text('$userPoints / ${LockedFeatureCard.requiredPoints} Hopoints', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.bold)),
          if (canGenerate) ...[
            const SizedBox(height: 24.0),
            Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onGenerate, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo.shade600, padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.indigo.shade600, fontWeight: FontWeight.bold), minimumSize: const Size(double.infinity, 50)), child: const Text('Generar Action Item'))),
          ]
        ]),
      ),
    );
  }
}

class _ActiveActionItemView extends StatelessWidget {
  final ActionItem item;
  const _ActiveActionItemView({required this.item});
  
  @override
  Widget build(BuildContext context) {
    final double progress = item.totalCount > 0 ? item.currentCount / item.totalCount : 0.0;
    return DashboardCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.check_circle_outline, size: 40.0, color: Colors.green.shade500),
          const SizedBox(width: 16.0),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Action Item Activo', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
            Text(item.title, style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ])),
        ]),
        const SizedBox(height: 16.0),
        ClipRRect(borderRadius: BorderRadius.circular(10.0), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade300, color: Colors.green, minHeight: 10)),
        const SizedBox(height: 8.0),
        Text('${item.currentCount} / ${item.totalCount} Completados', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _UnderConstructionView extends StatelessWidget {
  const _UnderConstructionView();
  
  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: SizedBox(height: 250, child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.construction, size: 50.0, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16.0),
        Text('Action Item en construcción...', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
        const SizedBox(height: 8.0),
        Text('Estamos trabajando en tu plan personalizado. Esto podría tardar un momento.', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
        const SizedBox(height: 16.0),
        CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)),
      ])),
    );
  }
}

class _ReadyToClaimView extends StatelessWidget {
  final VoidCallback onClaim;
  const _ReadyToClaimView({required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: SizedBox(height: 250, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Icon(Icons.card_giftcard, size: 50, color: Colors.green.shade600),
        const SizedBox(height: 16),
        Text('Tu plan está listo', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Pulsa el botón para reclamar tu Action Item.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onClaim, style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))), child: const Text('Reclamar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      ])),
    );
  }
}