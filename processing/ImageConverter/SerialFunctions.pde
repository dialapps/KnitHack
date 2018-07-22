public void Connect() {
  String pngImage = imageFilePath + "_BlackAndWith" + bwimg.width + "x" + bwimg.height +".png";
  bwimg.updatePixels();
  bwimg.save(pngImage);
  println(imageFilePath, "saved as png to: ", pngImage);
  done.trigger();
}

public void Send_to_KnittingMachine(int theValue) {
  //sending pixelBin[][] to knitting Machine! 
  patternSend();
}

public void Back() {
  //sending one before of pixelBin[][].
  if (header > 1) {
    header--; 
    for (int i=0; i<maxColumn; i++) {
      if (storeBin[header][i] == 2) {
        port.write(0);
        //      print(0);
      } else {
        port.write(storeBin[header][i]);
        //      print(storeBin[header][i]);
      }
    }
    //  print('\n');
    port.write(carriageMode);
    port.write(footer);
    print(header);
    println("sent");
    //  sendStatus[header][0] = true;
    back.trigger();
    port.clear();
  }
}

void serialEvent(Serial p) {
  /*
  two function
   1. send row of image data if get a cue (0~200)
   2. print receive data to debug
   */

  receivedData = p.read();

  if (receivedData == callCue) {
    header = int(header);
    patternSend();
  } else if (receivedData == doneCue) {
    print('\n');
  } else {
    print(receivedData);
  }
}

void patternSend() {
  if (header < row - 1) {
    for (int i=0; i<maxColumn; i++) {
      if (storeBin[header][i] == 2) {
        port.write(0);
      } else {
        port.write(storeBin[header][i]);
      }
    }
    port.write(carriageMode);
    port.write(footer);
    completeFlag = false;
    sent.trigger();
    header++;
  } else if (header == row - 1 && !completeFlag) {
    println("completed!");
    done.trigger();
    for (int i=0; i<row; i++) {
      header = 0;
    }
    completeFlag = true;
  } else {
    error.trigger();
  }
  println("header is " + header + ", displayStartRow is " + displayStartRow);

  //auto scroll
  if (header > 150) {
    if (header < row - 50) {
      displayStartRow = header - 150;
    } else {
      displayStartRow = row - 200;
    }
  } else {
    displayStartRow = 0;
  }
}