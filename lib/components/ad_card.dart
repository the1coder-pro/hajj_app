// import 'package:animations/animations.dart';
// import 'package:flutter/material.dart';
// import 'package:hajj_app/components/ad_detail.dart';

// class AdCardWidget extends StatelessWidget {
//   const AdCardWidget(
//       {super.key,
//       required this.title,
//       required this.description,
//       required this.imageURL,
//       required this.link});

//   final String imageURL;
//   final String title;
//   final String description;
//   final String link;

//   @override
//   Widget build(BuildContext context) {
//     return OpenContainer(
//       closedElevation: 0,
//       openBuilder: (BuildContext context, void Function() action) {
//         return AdDetailsPage(
//             imageURL: imageURL,
//             title: title,
//             description: description,
//             link: link);
//       },
//       closedBuilder: (BuildContext context, void Function() action) => Card(
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         elevation: 2,
//         margin: const EdgeInsets.all(10),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: 335,
//               height: 150,
//               child: Image.network(imageURL, fit: BoxFit.cover, frameBuilder:
//                   (context, child, frame, wasSynchronouslyLoaded) {
//                 if (wasSynchronouslyLoaded) {
//                   return child;
//                 } else {
//                   return AnimatedOpacity(
//                     duration: const Duration(milliseconds: 500),
//                     opacity: frame == null ? 0 : 1,
//                     child: child,
//                   );
//                 }
//               }, errorBuilder: (context, error, stackTrace) {
//                 return const Center(child: Text("لا يمكن تحميل الصورة"));
//               }, loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) {
//                   return child;
//                 } else {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//               }),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(title,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge!
//                       .copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
