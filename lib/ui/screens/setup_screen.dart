import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'role_reveal_screen.dart';

/// Pantalla principal de configuración del juego
///
/// Implementa:
/// - Gestión dinámica de jugadores (agregar/eliminar)
/// - Selector de categorías en grilla
/// - Slider para número de impostores
/// - Validación de configuración mínima
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _titleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(gameStateProvider.notifier).addPlayer(name);
      _nameController.clear();
      _nameFocusNode.requestFocus();
      // Feedback háptico
      HapticFeedback.lightImpact();
    }
  }

  void _removePlayer(String playerId) {
    ref.read(gameStateProvider.notifier).removePlayer(playerId);
    HapticFeedback.lightImpact();
  }

  void _startGame() {
    final gameState = ref.read(gameStateProvider);
    final selectedCategories = ref
        .read(categoriesProvider)
        .where((c) => c.isSelected)
        .toList();

    if (gameState.players.length < 3) {
      _showError('Se necesitan al menos 3 jugadores');
      return;
    }

    if (selectedCategories.isEmpty) {
      _showError('Selecciona al menos una categoría');
      return;
    }

    // Actualizar categorías seleccionadas en el estado del juego
    ref
        .read(gameStateProvider.notifier)
        .updateSelectedCategories(selectedCategories);

    // Iniciar el juego
    ref.read(gameStateProvider.notifier).startGame();

    // Feedback háptico
    HapticFeedback.mediumImpact();

    // Navegar a la pantalla de revelación de roles
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleRevealScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.dangerNeon),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.dangerNeon),
        ),
      ),
    );
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCount = categories.where((c) => c.isSelected).length;
    final maxImpostors = (gameState.players.length - 1).clamp(1, 10);

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header con título animado
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _titleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _titleAnimation.value,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AppTheme.primaryNeon,
                                  AppTheme.secondaryNeon,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'IMPOSTOR',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: AppTheme.primaryNeon
                                              .withValues(alpha: 0.5),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Quién es el espía?',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              // Sección de Jugadores
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildPlayersSection(gameState),
                ),
              ),

              // Sección de Categorías
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildCategoriesSection(categories, selectedCount),
                ),
              ),

              // Sección de Configuración
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSettingsSection(gameState, maxImpostors),
                ),
              ),

              // Botón de iniciar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildStartButton(gameState, selectedCount),
                ),
              ),

              // Espaciado inferior
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersSection(GameState gameState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: AppTheme.primaryNeon),
                const SizedBox(width: 8),
                Text(
                  'Jugadores',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: gameState.players.length >= 3
                    ? AppTheme.accentNeon.withValues(alpha: 0.2)
                    : AppTheme.dangerNeon.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: gameState.players.length >= 3
                      ? AppTheme.accentNeon
                      : AppTheme.dangerNeon,
                ),
              ),
              child: Text(
                '${gameState.players.length} / mín. 3',
                style: TextStyle(
                  color: gameState.players.length >= 3
                      ? AppTheme.accentNeon
                      : AppTheme.dangerNeon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Input para agregar jugadores
        Row(
          children: [
            Expanded(
              child: NeonTextField(
                controller: _nameController,
                hintText: 'Nombre del jugador',
                prefixIcon: Icons.person_add,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addPlayer(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryNeon,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNeon.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _addPlayer,
                icon: const Icon(Icons.add, color: AppTheme.backgroundDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista de jugadores
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            children: gameState.players.asMap().entries.map((entry) {
              return PlayerCard(
                key: ValueKey(entry.value.id),
                name: entry.value.name,
                index: entry.key,
                onDelete: () => _removePlayer(entry.value.id),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(List<Category> categories, int selectedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: AppTheme.secondaryNeon),
                const SizedBox(width: 8),
                Text(
                  'Categorías',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                if (selectedCount == categories.length) {
                  ref.read(categoriesProvider.notifier).deselectAll();
                } else {
                  ref.read(categoriesProvider.notifier).selectAll();
                }
                HapticFeedback.selectionClick();
              },
              icon: Icon(
                selectedCount == categories.length
                    ? Icons.deselect
                    : Icons.select_all,
                size: 18,
              ),
              label: Text(
                selectedCount == categories.length ? 'Ninguna' : 'Todas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$selectedCount categorías seleccionadas',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),

        // Grilla de categorías
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((category) {
            return CategoryChip(
              label: category.name,
              icon: category.icon,
              isSelected: category.isSelected,
              onTap: () {
                ref
                    .read(categoriesProvider.notifier)
                    .toggleCategory(category.id);
                HapticFeedback.selectionClick();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(GameState gameState, int maxImpostors) {
    return NeonCard(
      glowColor: AppTheme.warningNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: AppTheme.warningNeon),
              const SizedBox(width: 8),
              Text(
                'Configuración',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.warningNeon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Slider de impostores
          Row(
            children: [
              const Icon(
                Icons.visibility_off,
                color: AppTheme.dangerNeon,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Impostores:'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.dangerNeon.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.dangerNeon),
                ),
                child: Text(
                  '${gameState.impostorCount}',
                  style: const TextStyle(
                    color: AppTheme.dangerNeon,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.dangerNeon,
              inactiveTrackColor: AppTheme.dangerNeon.withValues(alpha: 0.2),
              thumbColor: AppTheme.dangerNeon,
              overlayColor: AppTheme.dangerNeon.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: gameState.impostorCount.toDouble(),
              min: 1,
              max: maxImpostors.toDouble(),
              divisions: maxImpostors > 1 ? maxImpostors - 1 : 1,
              onChanged: gameState.players.length >= 3
                  ? (value) {
                      ref
                          .read(gameStateProvider.notifier)
                          .setImpostorCount(value.round());
                      HapticFeedback.selectionClick();
                    }
                  : null,
            ),
          ),
          if (gameState.players.length < 3)
            Text(
              'Agrega más jugadores para ajustar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),

          const Divider(height: 32),

          // Opción: Impostor ve categoría
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Impostor ve la categoría'),
            subtitle: Text(
              gameState.impostorSeesCategory
                  ? 'El impostor verá la categoría general'
                  : 'El impostor no tendrá ninguna pista',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: gameState.impostorSeesCategory,
            onChanged: (value) {
              ref
                  .read(gameStateProvider.notifier)
                  .setImpostorSeesCategory(value);
              HapticFeedback.selectionClick();
            },
            activeTrackColor: AppTheme.primaryNeon,
            thumbColor: WidgetStateProperty.all(AppTheme.primaryNeon),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(GameState gameState, int selectedCount) {
    final canStart = gameState.players.length >= 3 && selectedCount > 0;

    return Column(
      children: [
        NeonButton(
          text: 'INICIAR PARTIDA',
          icon: Icons.play_arrow,
          color: canStart ? AppTheme.accentNeon : AppTheme.textMuted,
          expanded: true,
          onPressed: canStart ? _startGame : null,
        ),
        if (!canStart) ...[
          const SizedBox(height: 12),
          Text(
            gameState.players.length < 3
                ? 'Necesitas al menos 3 jugadores'
                : 'Selecciona al menos una categoría',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.dangerNeon),
          ),
        ],
      ],
    );
  }
}
