import 'package:flutter/material.dart';
import 'package:opn_test_template/app/features/topics/model/topic_type_model.dart';

import '../../model/question_model.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls({
    super.key,
    required this.controller,
    required this.questions,
    required this.currentIndex,
    required this.onFinish,
    required this.isFinishing,
    required this.testFinished,
    required this.topicType,
  });

  final PageController controller;
  final List<Question> questions;
  final TopicType ? topicType;
  final int currentIndex;
  final VoidCallback onFinish;
  final bool isFinishing;
  final bool testFinished;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < questions.length - 1;

    if (testFinished) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: colors.primary,
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: hasPrevious,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: IconButton(
                  onPressed: controller.hasClients
                      ? () {
                          final previous = currentIndex - 1;
                          controller.animateToPage(
                            previous,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              Flexible(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onFinish,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    label: const Text('Ver resultados'),
                  ),
                ),
              ),
              Visibility(
                visible: hasNext,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: IconButton(
                  onPressed: controller.hasClients
                      ? () {
                          final next = currentIndex + 1;
                          controller.animateToPage(
                            next,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

      );
    }


    const mainButtonText = 'Finalizar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: hasPrevious ,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                onPressed: isFinishing || !controller.hasClients
                    ? null
                    : () {
                        final previous = currentIndex - 1;
                        controller.animateToPage(
                          previous,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: isFinishing ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isFinishing ? null : onFinish,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: colors.primary.withValues(alpha: 0.7),
                  ),
                  child: isFinishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(mainButtonText),
                ),
              ),
            ),
            Visibility(
              visible: hasNext,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                onPressed: isFinishing || !controller.hasClients
                    ? null
                    : () {
                        final next = currentIndex + 1;
                        controller.animateToPage(
                          next,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isFinishing ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                ),
              ),
            ),
          ],
        ),

    );
  }
}
