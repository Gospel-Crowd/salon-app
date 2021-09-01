import 'package:image_picker/image_picker.dart';

Future<XFile> imagePicker() async {
  final ImagePicker imagePicker = ImagePicker();
  XFile imageFile;
  try {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    imageFile = pickedFile;
  } catch (e) {
    print(e);
  }
  return imageFile;
}
