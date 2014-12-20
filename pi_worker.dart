import "dart:math";
import "workers.dart";

void main(args, port) {
  var socket = new WorkerSocket.worker(port);
  
  socket.listen((i) {
    socket.add(4 * pow(-1, i) / ((2 * i) + 1));
  });
}