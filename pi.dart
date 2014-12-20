import "dart:async";
import "dart:io";
import "workers.dart";

int isolates = Platform.numberOfProcessors;
int per = 900000;

double pi = 0.0;

void main() {
  print("Warming up...");
  
  {
    int grandTotal = 0;
    for (var time in range(1, 50)) {
      int total = 0;
      for (var number in range(0, per * 5)) {
        total += number;
      }
      grandTotal += total;
    }
  }
  
  print("Warm up complete.");
  
  print("Spawning workers...");
  
  for (var isolateNumber in range(0, isolates - 1)) {
    counts[isolateNumber] = 0;
    var worker = workers[isolateNumber] = createWorkerScript("pi_worker.dart", args: ["${isolateNumber}"]);
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