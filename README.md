



## 1.扩展外部窗体

xiebroC2提供了简单的插件接口，它可以降低插件编写的门槛，并且实现CobaltStrike那样的插件体系

例如要在控制端的顶部菜单栏添加一个shellcode分离加载器：

<video src="https://private-user-images.githubusercontent.com/89376703/311126700-913d66d5-fe82-459a-8b3d-ea73682a9bb7.mp4?" width="640" height="480" controls></video>



- 将Winform .Net程序转成XiebroC2的lua插件

```powershell
 Import-Module .\Convert-NetToLua.ps1
 Convert-NetToLua -infile .\Plugins.exe -Output a.lua -Name loader
```

在编写winform的时候需要注意的是，你要将入口点修改成下面这样，如果是Application.EnableVisualStyles启动，在被转成lua插件时，主控端加载会报错

```C#
internal static class Program
{
    /// <summary>
    /// 应用程序的主入口点。
    /// </summary>
    [STAThread]
    static void Main()
    {
         Form1 form1 = new Form1();
         form1.ShowDialog();
    }
}
```



## 2.扩展Session 命令

![image-20240308134300864](C:\Users\Lenovo\AppData\Roaming\Typora\typora-user-images\image-20240308134300864.png)



在命令列表中添加外部命令

```lua
AddCommand(
    "SharpKatz", --Name
    "Plugins\\SharpKatz.exe", -- FilePath
    "execute-assembly", --load type
    "Steal domain login credentials",  --Descripttion
    "SharpKatz -h" --Usage
)
```

- AddCommand第三个参数有三种加载方式，如果是.net 程序集则选择“execute-assembly”、“Inline-assembly” ，如果是C/C++/Golang/rust/nim编写的PE文件则选择RunPE

## 3.扩展功能菜单栏

