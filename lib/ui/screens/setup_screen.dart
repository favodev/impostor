import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import 'role_reveal_screen.dart';

/// Pantalla de configuración de partida
///
/// Diseño limpio con:
/// - Campo para agregar jugadores
/// - Lista de jugadores agregados
/// - Selector de número de impostores
/// - Toggle para pista
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(gameStateProvider.notifier).addPlayer(name);
      _nameController.clear();
      _nameFocusNode.requestFocus();
      HapticFeedback.lightImpact();
    }
  }

  void _removePlayer(String playerId) {
    ref.read(gameStateProvider.notifier).removePlayer(playerId);
    HapticFeedback.lightImpact();
  }

  void _startGame() {
    final gameState = ref.read(gameStateProvider);
    final categories = ref.read(categoriesProvider);

    if (gameState.players.length < 3) {
      _showError('Se necesitan al menos 3 jugadores');
      return;
    }

    // Seleccionar todas las categorías automáticamente
    ref.read(gameStateProvider.notifier).updateSelectedCategories(categories);

    // Iniciar el juego
    ref.read(gameStateProvider.notifier).startGame();

    HapticFeedback.mediumImpact();

    // Navegar a la pantalla de revelación de roles
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleRevealScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
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
        backgroundColor: const Color(0xFF2A1B4D),
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
    final maxImpostors = (gameState.players.length - 1).clamp(1, 10);

    return Scaffold(
      backgroundColor: AppTheme.backgroundIndigo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppTheme.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
          ).createShader(bounds),
          child: const Text(
            'NUEVA PARTIDA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Agregar Jugadores
                    _buildSectionTitle('JUGADORES', Icons.people_rounded),
                    const SizedBox(height: 16),
                    _buildPlayerInput(),
                    const SizedBox(height: 16),
                    _buildPlayersList(gameState.players),

                    const SizedBox(height: 32),

                    // Sección: Configuración
                    _buildSectionTitle('CONFIGURACIÓN', Icons.settings_rounded),
                    const SizedBox(height: 16),
                    _buildImpostorSelector(gameState, maxImpostors),
                    const SizedBox(height: 16),
                    _buildHintToggle(gameState),
                  ],
                ),
              ),
            ),

            // Botón Iniciar
            _buildStartButton(gameState),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryNeon,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryNeon,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryNeon.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Nombre del jugador',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _addPlayer(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _addPlayer,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.backgroundIndigo,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList(List<Player> players) {
    if (players.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.textMuted.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.person_add_rounded,
                size: 40,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega al menos 3 jugadores',
                style: TextStyle(
                  color: AppTheme.textMuted.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: players.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.secondaryNeon.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Número
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryNeon.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.secondaryNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre
              Expanded(
                child: Text(
                  player.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              // Botón eliminar
              IconButton(
                onPressed: () => _removePlayer(player.id),
                icon: Icon(
                  Icons.close_rounded,
                  color: AppTheme.dangerNeon.withValues(alpha: 0.7),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImpostorSelector(GameState gameState, int maxImpostors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dangerNeon.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_off_rounded,
                color: AppTheme.dangerNeon,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Número de Pillos',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.dangerNeon.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${gameState.impostorCount}',
                  style: const TextStyle(
                    color: AppTheme.dangerNeon,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.dangerNeon,
              inactiveTrackColor: AppTheme.dangerNeon.withValues(alpha: 0.2),
              thumbColor: AppTheme.dangerNeon,
              overlayColor: AppTheme.dangerNeon.withValues(alpha: 0.2),
              trackHeight: 4,
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
                          .setImpostorCount(value.toInt());
                    }
                  : null,
            ),
          ),
          if (gameState.players.length < 3)
            Text(
              'Agrega jugadores para ajustar',
              style: TextStyle(
                color: AppTheme.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHintToggle(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningNeon.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.warningNeon,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pista para el Pillo',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gameState.impostorSeesHint
                      ? 'Verá una palabra relacionada'
                      : 'Sin pistas, más difícil',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: gameState.impostorSeesHint,
            onChanged: (value) {
              ref.read(gameStateProvider.notifier).setImpostorSeesHint(value);
            },
            activeThumbColor: AppTheme.warningNeon,
            activeTrackColor: AppTheme.warningNeon.withValues(alpha: 0.3),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.textMuted.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(GameState gameState) {
    final canStart = gameState.players.length >= 3;

    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canStart ? _startGame : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                canStart ? AppTheme.primaryNeon : AppTheme.textMuted,
            foregroundColor: AppTheme.backgroundIndigo,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            canStart
                ? 'INICIAR PARTIDA'
                : 'AGREGA ${3 - gameState.players.length} JUGADOR${gameState.players.length == 2 ? "" : "ES"} MÁS',
            style: TextStyle(
              color: canStart
                  ? AppTheme.backgroundIndigo
                  : AppTheme.backgroundIndigo.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
