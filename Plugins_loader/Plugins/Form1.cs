using dnlib.DotNet;
using dnlib.DotNet.Emit;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Windows.Forms;



namespace Plugins
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }


        private void button1_Click(object sender, EventArgs e)
        {
            // Assuming Properties.Resources.WindowsFormsApp1 is a byte array representing the assembly
            ModuleDefMD asmDef = ModuleDefMD.Load(Properties.Resources.WindowsFormsApp1);

            WriteSettings.WriteSetting(asmDef, textBox1.Text);
            using (SaveFileDialog saveFileDialog1 = new SaveFileDialog())
            {
                saveFileDialog1.Filter = ".exe (*.exe)|*.exe";
                saveFileDialog1.InitialDirectory = Application.StartupPath;
                saveFileDialog1.OverwritePrompt = false;
                saveFileDialog1.FileName = "main";

                if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                {

                    try
                    {
                        asmDef.Write(saveFileDialog1.FileName);
                        asmDef.Dispose();
                        MessageBox.Show("Assembly modified and saved to: " + saveFileDialog1.FileName);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(ex.Message);
                    }
                }
            }
           
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }
    }
}
