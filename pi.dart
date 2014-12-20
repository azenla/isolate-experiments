import "dart:async";
import "dart:io";
import "dart:math";
import "workers.dart";

int isolates = Platform.numberOfProcessors;
int per = 900000;

void _worker(port) {
  var socket = new WorkerSocket.worker(port);
  
  socket.listen((i) {
    socket.add(4 * pow(-1, i) / ((2 * i) + 1));
  });
}

double pi = 0.0;

void main() {
  print("Spawning workers...");
  
  for (var isolateNumber in range(0, isolates - 1)) {
    counts[isolateNumber] = 0;
    var worker = workers[isolateNumber] = createWorker(_worker);
    worker.listen((data) {
      pi += data;
      counts[isolateNumber] = counts[isolateNumber] + 1;
      
      if (counts[isolateNumber] == per) {
        print("Worker ${isolateNumber} is done.");
        worker.close();
      }
    });
  }
  
  Future.wait(workers.values.map((it) => it.done).toList()).then((_) {
    print("All workers are done.");
    print("PI = ${pi}");
  });
  
  Future.wait(workers.values.map((it) => it.waitFor()).toList()).then((_) {
    print("Workers are ready.");
    for (var isolateNumber in workers.keys) {
      var worker = workers[isolateNumber];
      var numbers = range(isolateNumber * per, per + (per * isolateNumber));
      for (var number in numbers) {
        worker.add(number);
      }
    }
  });
}

num average(List<num> numbers) {
  return numbers.reduce((a, b) => a + b) / numbers.length;
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


Map<int, WorkerSocket> workers = {};
Map<int, int> counts = {};