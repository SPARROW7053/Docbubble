import os

kernel_path = r"C:\Users\ANKAN\Desktop\My Projects\Flutter\Pdf Doc scanner app\build\app\intermediates\flutter\debug\flutter_assets\kernel_blob.bin"

with open(kernel_path, "rb") as f:
    data = f.read()

pos2 = 95752347
uri = b"file:///C:/Users/ANKAN/Desktop/My%20Projects/Flutter/Pdf%20Doc%20scanner%20app/lib/models/document_model.dart"

end_uri = pos2 + len(uri)
print("Bytes after document_model.dart:")
print(data[end_uri : end_uri + 20])
