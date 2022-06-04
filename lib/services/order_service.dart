import 'package:roslibdart/core/topic.dart';

class OrderService {


  void publishOrder(int x,Topic order) async {
    var msg = {'data': x};
    await order.publish(msg);
  }
  move(String ord, Topic order) {
    if (ord == "forward") {
      publishOrder(1, order);
      // print("done forwarding");
    } else if (ord == "backward") {
      publishOrder(2, order);
      // print("done backwarding");
    } else if (ord == "to the right") {
      publishOrder(3, order);
      // print("done moving right");
    } else if (ord == "to the left") {
      publishOrder(4, order);
      // print("done moving left");
    }
  }
}
