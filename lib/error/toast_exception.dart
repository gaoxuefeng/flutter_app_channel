/// Created by Gao Xuefeng
/// on 2021/6/30
class ServerException implements Exception {
  String code;
  String? toast;
  List<String>? messages;

  ServerException(this.code, this.toast, this.messages);

  @override
  String toString() {
    return 'ServerException{code: $code, toast: $toast, messages: $messages}';
  }
}

class ToastException implements Exception {
  String code;
  String? toast;
  String? message;

  ToastException(this.code, this.toast, this.message);

  @override
  String toString() {
    return 'ToastException{code: $code, toast: $toast, messages: $message}';
  }
}
