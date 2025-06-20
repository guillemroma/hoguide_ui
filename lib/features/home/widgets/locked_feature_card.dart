import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../services/auth_service.dart';
import '../../../common/widgets/dashboard_card.dart';

enum ActionState { initializing, locked, initial, loading, success }

class LockedFeatureCard extends StatefulWidget {
  final int userPoints;
  final String authToken;

  const LockedFeatureCard({super.key, required this.userPoints, required this.authToken});

  static const int requiredPoints = 14;

  @override
  State<LockedFeatureCard> createState() => _LockedFeatureCardState();
}

class _LockedFeatureCardState extends State<LockedFeatureCard> {
  late ActionState _currentState = ActionState.initializing;
  ActionItem? _finalActionItem;
  Timer? _timer;
  
  bool _isClaiming = false;
  bool _canClaimManually = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    final actionItem = await AuthService.fetchFirstActionItem(widget.authToken);

    if (!mounted) return;
    
    if (actionItem == null) {
      setState(() {
        _currentState = (widget.userPoints >= LockedFeatureCard.requiredPoints)
            ? ActionState.initial
            : ActionState.locked;
      });
    } else {
       if (actionItem.description == 'in_progress') {
         _showLoadingAndStartTimer();
       } else {
         setState(() {
           _currentState = ActionState.success;
           _finalActionItem = actionItem;
         });
       }
    }
  }

  @override
  void didUpdateWidget(LockedFeatureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userPoints != oldWidget.userPoints) {
      _updateStateBasedOnPoints();
    }
  }

  void _updateStateBasedOnPoints() {
    if (_currentState == ActionState.loading || _currentState == ActionState.success || _currentState == ActionState.initializing) {
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

  // --- LÓGICA DE NEGOCIO ---

  void _showLoadingAndStartTimer() {
    if (!mounted) return;
    
    setState(() {
      _currentState = ActionState.loading;
      _canClaimManually = false; 
    });

    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 5), () {
      if (mounted && _currentState == ActionState.loading) {
        setState(() => _canClaimManually = true);
      }
    });
  }
  
  Future<void> _initiateAndStartTimer() async {
    final bool success = await AuthService.generateActionItem(widget.authToken);

    if (!mounted) return;

    if (success) {
      _showLoadingAndStartTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar la generación. Inténtalo de nuevo.')),
      );
      if (mounted) {
        setState(() => _currentState = ActionState.initial);
      }
    }
  }

  Future<void> _claimReward() async {
    if (_isClaiming) return;

    setState(() => _isClaiming = true);
    
    final actionItem = await AuthService.fetchFirstActionItem(widget.authToken);

    if (!mounted) return;

    if (actionItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró un Hábito activo. Inténtalo más tarde.')),
      );
      setState(() {
        _currentState = ActionState.initial;
        _isClaiming = false;
        _canClaimManually = false;
      });
      return;
    }

    if (actionItem.description == 'in_progress') {
      setState(() {
        _isClaiming = false;
        _canClaimManually = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El plan aún se está generando. Inténtalo de nuevo en unos minutos.')),
      );
    } else {
      setState(() {
        _currentState = ActionState.success;
        _finalActionItem = actionItem;
        _isClaiming = false;
        _canClaimManually = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case ActionState.initializing:
        return const DashboardCard(child: Center(child: CircularProgressIndicator()));
      
      case ActionState.locked:
        return RepaintBoundary(
          child: _LockedView(userPoints: widget.userPoints, onGenerate: () {})
        );
      
      case ActionState.initial:
        return RepaintBoundary(
          child: _LockedView(userPoints: widget.userPoints, onGenerate: _initiateAndStartTimer)
        );
      
      case ActionState.loading:
        return RepaintBoundary(
          child: _UnderConstructionView(
            canClaimManually: _canClaimManually,
            isClaiming: _isClaiming,
            onClaim: _claimReward,
          )
        );
      
      case ActionState.success:
        return _finalActionItem != null
            ? RepaintBoundary(child: _ActiveActionItemView(item: _finalActionItem!))
            : const Center(child: Text("Error al mostrar el item."));
    }
  }
}

// --- WIDGETS DE UI ---

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 32.0, color: Colors.indigo.shade400),
              const SizedBox(width: 16.0),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hábitos', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text('Consigue ${LockedFeatureCard.requiredPoints} Hopoints y desbloquea tu plan.', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ])),
              if (canGenerate)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onGenerate,
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.indigo.shade600,
                    ),
                    tooltip: 'Generar Hábito',
                  ),
                ),
            ]
          ),
          const SizedBox(height: 16.0),
          ClipRRect(borderRadius: BorderRadius.circular(10.0), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.7), color: Colors.deepPurple, minHeight: 10)),
          const SizedBox(height: 8.0),
          Text('$userPoints / ${LockedFeatureCard.requiredPoints} Hopoints', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

class _ActiveActionItemView extends StatelessWidget {
  final ActionItem item;
  const _ActiveActionItemView({required this.item});

  void _showDescriptionDialog(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hábito',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_task, color: Colors.green.shade700, size: 20,),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'El Hábito ha sido añadido a tu Cuestionario Diario.',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.green.shade800
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final double progress = item.totalCount > 0 ? (item.currentCount / item.totalCount).clamp(0.0, 1.0) : 0.0;
    return DashboardCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, size: 32.0, color: Colors.green.shade500),
            const SizedBox(width: 16.0),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // UI-UPDATE: "Action Item Activo" ahora es el título principal.
              Text(
                'Hábito Activo',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 4.0),
              // UI-UPDATE: Texto genérico como subtítulo.
              Text(
                'Clica para obtener más información.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ])),
            IconButton(
              icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
              onPressed: () => _showDescriptionDialog(context, item.description),
              tooltip: 'Ver descripción',
            )
          ]
        ),
        const SizedBox(height: 16.0),
        ClipRRect(borderRadius: BorderRadius.circular(10.0), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade300, color: Colors.green, minHeight: 10)),
        const SizedBox(height: 8.0),
        Text('${item.currentCount} / ${item.totalCount} Completados', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _UnderConstructionView extends StatelessWidget {
  final bool canClaimManually;
  final bool isClaiming;
  final VoidCallback onClaim;

  const _UnderConstructionView({
    required this.canClaimManually,
    required this.isClaiming,
    required this.onClaim,
  });
  
  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, 
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.construction, size: 32.0, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hábito en construcción...', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4.0),
                    Text('Tu Hábito personalizado se está generando. Este proceso puede tardar unos minutos...', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              RepaintBoundary(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: canClaimManually
                    ? Container(
                        key: const ValueKey('claim_icon'),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: isClaiming 
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.green),
                              ),
                            )
                          : IconButton(
                              onPressed: onClaim,
                              icon: const Icon(Icons.sync, color: Colors.green),
                              tooltip: 'Reclamar manualmente',
                            ),
                      )
                    : Padding(
                      key: const ValueKey('loader_placeholder'),
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                      ),
                    ),
                ),
              ),
            ],
          ),
      ]),
    );
  }
}
