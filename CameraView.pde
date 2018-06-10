import processing.video.*;
import java.lang.reflect.Field;
import kyui.core.*;
import kyui.element.AlterLinearLayout;
import kyui.element.DropDown;
import kyui.element.ImageButton;
import kyui.util.Rect;
Capture webcam;
AlterLinearLayout layout;
DropDown down;
ImageButton exit;
//http://www.visualinformation.org/2009/09/transparent-application-window-in-processing/
void setup() {
  KyUI.start(this, 30, true);
  //surface.setTitle();
  //surface.setIcon();
  fullScreen();
  surface.setSize(500, 500);
  surface.setLocation(displayWidth-width, displayHeight-height);
  try {
    surface.setVisible(false);
    //frame.setUndecorated(true);
    Field field=java.awt.Frame.class.getDeclaredField("undecorated");
    field.setAccessible(true);
    field.set(frame, true);
    surface.setVisible(true);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  surface.setAlwaysOnTop(true);
  //surface.setResizable(true);//no effect
  frameRate(30);  
  final String[] devices = Capture.list();
  webcam = new Capture(this, devices[0]);
  webcam.start();
  layout=new AlterLinearLayout("layout");
  down=new DropDown("down");
  down.textSize=15;
  exit=new ImageButton("exit");
  exit.scaled=true;
  exit.padding=5;
  exit.image=loadImage("exit.png");
  exit.setPressListener(new kyui.event.MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      exit();
      return false;
    }
  }
  );
  for (String s : devices) {
    println(s);
    down.addItem(s);
  }
  down.text=devices[0];
  final PApplet sketch=this;
  down.setSelectListener(new ItemSelectListener() {
    public void onEvent(int index) {
      //println("selected : "+index);
      webcam.stop();
      webcam = new Capture(sketch, devices[index]);
      webcam.start();
    }
  }
  );
  try {
    Field picker=DropDown.class.getDeclaredField("picker");
    Field field=Element.class.getDeclaredField("clipping");
    picker.setAccessible(true);
    field.setAccessible(true);
    kyui.element.LinearList list=(kyui.element.LinearList)picker.get(down);
    field.set(list, false);
  }
  catch(Exception e) {
    e.printStackTrace();
  }

  layout.addChild(down);
  layout.addChild(exit);
  KyUI.add(layout);
  KyUI.taskManager.executeAll();
  layout.set(down, AlterLinearLayout.LayoutType.STATIC, 1);
  layout.set(exit, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
  layout.setPosition(new Rect(0, 0, width, 50));
  KyUI.changeLayout();
  down.setBgColor(color(50, 100));
  down.textColor=color(255, 254);
  exit.image.loadPixels();
  for (int a=0; a<exit.image.pixels.length; a++) {
    if (alpha(exit.image.pixels[a])!=0) {
      exit.image.pixels[a]=color(255, 255, 255, 150);
    }
  }
  exit.setBgColor(down.bgColor);
  KyUI.getRoot().invalidate();
}
void draw() {
  //background(255);
  if (webcam.available()) {
    webcam.read();
  }
  KyUI.getRoot().invalidate();
  image(webcam, width/2, height/2);
  KyUI.render(g);
  if (webcam.width!=0&&webcam.height!=0&&width!=webcam.width) {
    println("resize to "+webcam.width+" "+webcam.height);
    surface.setSize(webcam.width, webcam.height);
    surface.setLocation(displayWidth-width, displayHeight-height);
    down.resize(width, height);
    layout.setPosition(new Rect(0, 0, width, 30));
    KyUI.changeLayout();
  }
}
protected void handleMouseEvent(MouseEvent e) {
  KyUI.handleEvent(e);
}
protected void handleKeyEvent(KeyEvent e) {
  KyUI.handleEvent(e);
}