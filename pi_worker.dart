import "dart:math";
import "workers.dart";

void main(args, port) {
  var number = int.parse(args[0]);
  print("Worker ${number} started.");
  print("Worker ${number} warming up.");
  {
    int grandTotal = 0;
    for (var time in range(1, 50)) {
      int total = 0;
      for (var number in range(0, 500000 * 5)) {
        total += number;
      }
      grandTotal += total;
    }
  }
  print("Worker ${number} warmed up.");
  
  var socket = new WorkerSocket.worker(port);
  
  socket.listen((i) {
    socket.add(4 * pow(-1, i) / ((2 * i) + 1));
  });
}

List<int> range(int start, int end) {
  var range = [];

  var minus = false;

  if (end < start) {
    minus = true;
  }

  for (int i = start; i <= end; minus ? i-- : i++) {
    range.add(i);
  }
  return range;
}