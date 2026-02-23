import 'package:flutter/material.dart';
import 'package:frontend/core/models/time_period.dart';

class SpendingFilterBar extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onTimePeriodChanged;
  const SpendingFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.onTimePeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text("BUTTON"),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text("BottomSheet"),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
