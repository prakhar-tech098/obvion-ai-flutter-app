// lib/presentation/state/generate_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/image_item.dart';
import '../../domain/usecases/generate_images.dart';

part 'generate_state.dart';

class GenerateCubit extends Cubit<GenerateState> {
  final GenerateImages generateImages;
  GenerateCubit({required this.generateImages}) : super(const GenerateState.initial());

  Future<void> generatePrompt({required String modelId, required String prompt, int count = 2}) async {
    try {
      emit(state.copyWith(status: GenerateStatus.generating));
      final images = await generateImages.byPrompt(modelId: modelId, prompt: prompt, count: count);
      emit(state.copyWith(status: GenerateStatus.ready, images: images));
    } catch (e) {
      emit(state.copyWith(status: GenerateStatus.failed, error: e.toString()));
    }
  }
}
