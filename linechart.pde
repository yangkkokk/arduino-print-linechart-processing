import processing.serial.*;

Serial port;  // 串口
int val[];      // 串口数据
int channels = 5;//通道数量
int[][] values;
int[] palette = new int[]{#ffffff,#ff0000,#00ff00,#0000ff,#888800,#888888};//5个通道的颜色
void setup() 
{
  size(640, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  String[] ttys = Serial.list();
  println("BORKLET: " + ttys.length);
  port = new Serial(this, ttys[1], 9600);
  //打开串口
  values = new int[channels][width];
  //每个通道，和宽度
  val=new int[channels];
  smooth();//平滑等级
}



int getY(int val) {
  return (int)(val / 1023.0f * height) - 1;
}



void draw()
{
  
  while (port.available() >= 4) {
    //读取4个字节
    /*
当将单个字节发送到mega32u4的软件序列时，Serial.available（）永远不会返回除0或1之外的任何内容。

测试代码

void setup（）{ 
Serial.begin（9600）; 
} 
空隙环（）{ 
Serial.println（Serial.available（））; 
延迟（100）; 
}

我可以通过使用putty发送单个字节在客户端上重现这一点。

while（Serial.available（）<4）; 
将锁定程序。

while（Serial.available（）<4）{ 
if（serialEventRun）
serialEventRun（）; 
} 
不会死机的程序，但卡在与发送单字节的无限循环。如果我使用内置的串口监视器发送多个字节的字符串将退出循环。

示例：
Serial.available（）== 0 
发送一个字节
Serial.available（）== 1 
发送一个字节
Serial.available（）== 1

重启设备
Serial.available（）== 0 
在一个数据包中发送4个字节
Serial.available（）== 4 
发送1个字节
Serial.available（）== 4

这种行为与uno的硬件序列不同
    */
    if (port.read() == 0xff) {
      //如果读取到了0xff
      int channel =port.read();
      //再读取一次，储存位channel
      val[channel] = (port.read() << 8) | (port.read());
      //再次读取一次，储存到val[channel]的值
    }
  }
  background(0);
/*
  Serial.write( 0xff);                // send init byte
  Serial.write( 3 & 0xff);       // Send channel ID;
  Serial.write( (random(1,222) >> 8) & 0xff); // send first part
  Serial.write( random(1,222) & 0xff );        // send second part


 */   
  for (int c=0; c< channels; c++){
    //根据channels迭代

    int delta = values[c][width-1] - val[c];
//去除通道标号+分开数据


    for (int i=0; i<width-1; i++)
      values[c][i] = values[c][i+1];

    values[c][width-1] = val[c];
    //values弄出来
    stroke(palette[c]);
    //涂色
    text("C"+c+": "+val[c], 15,20+30*c,150,70);
    //val[c]区分通道后的值
    text("D: "+ delta, 150,20+30*c,150,70);

    for (int x=1; x<width; x++) {

      line(width-x,   height-1-getY(values[c][x-1]), 

        //画线函数,宽度-像素位置=当前低起点，高度-1-数值转化的高度.y位置-1

           width-1-x, height-1-getY(values[c][x]));
      
      //第二个位置x位置-1
    }
  }
}
