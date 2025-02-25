// import 'package:cstain/providers/campaign%20providers/praticipation_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ParticipateButton extends ConsumerWidget {
//   final String campaignId;

//   const ParticipateButton({Key? key, required this.campaignId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ElevatedButton(
//       onPressed: () async {
//         final userId = FirebaseAuth.instance.currentUser?.uid;
//         if (userId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User not logged in')),
//           );
//           return;
//         }

//         await ref
//             .read(participantProvider.notifier)
//             .participate(campaignId, userId);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Registered successfully!')),
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.teal,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//       child: const Text(
//         'Participate',
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }

//************************** with disable and participation model ************************* */
// import 'package:cstain/providers/action%20providers/providers.dart';
// import 'package:cstain/providers/campaign%20providers/praticipation_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ParticipateButton extends ConsumerWidget {
//   final String campaignId;

//   const ParticipateButton({Key? key, required this.campaignId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userId = ref.watch(userStreamProvider).value?.uid;

//     if (userId == null) {
//       return const Text("Log in to participate");
//     }

//     final participationState =
//         ref.watch(checkParticipationProvider(campaignId));

//     return participationState.when(
//       data: (hasParticipated) {
//         return ElevatedButton(
//           onPressed: hasParticipated
//               ? null // Disable button if already participated
//               : () async {
//                   await ref
//                       .read(participantProvider.notifier)
//                       .participate(campaignId, userId);

//                   // Refresh participation state
//                   ref.invalidate(checkParticipationProvider(campaignId));

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Registered successfully!')),
//                   );
//                 },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: hasParticipated ? Colors.grey : Colors.teal,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//           child: Text(
//             hasParticipated ? "Already Participated" : "Participate",
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//       loading: () => const CircularProgressIndicator(),
//       error: (err, stack) => Text("Error: $err"),
//     );
//   }
// }
import 'package:cstain/providers/action%20providers/providers.dart';
import 'package:cstain/providers/campaign%20providers/praticipation_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParticipateButton extends ConsumerWidget {
  final String campaignId;

  const ParticipateButton({Key? key, required this.campaignId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userStreamProvider).value?.uid;
    print("Participate button userId: $userId, campaignId: $campaignId");

    if (userId == null) {
      return const Text("Log in to participate");
    }

    final participationState =
        ref.watch(checkParticipationProvider(campaignId));

    return participationState.when(
      data: (hasParticipated) {
        return ElevatedButton(
          onPressed: hasParticipated
              ? null // Disable button if already participated
              : () async {
                  print(
                      "Participate button pressed, userId: $userId, campaignId: $campaignId");
                  await ref
                      .read(participantProvider.notifier)
                      .participate(campaignId, userId);

                  // Refresh participation state
                  //very important line if already participated in the button is not showing
                  // await Future.delayed(Duration(milliseconds: 500));
                  ref.invalidate(checkParticipationProvider(campaignId));
                  print(
                      "Participation provider invalidated for campaignId: $campaignId and user id is also $userId");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registered successfully!')),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: hasParticipated ? Colors.grey : Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            hasParticipated ? "Already Participated" : "Participate",
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text("Error: $err"),
    );
  }
}
