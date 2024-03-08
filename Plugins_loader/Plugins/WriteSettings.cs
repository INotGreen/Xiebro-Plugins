using dnlib.DotNet;
using dnlib.DotNet.Emit;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Plugins
{
    internal class WriteSettings
    {
        public static void WriteSetting(ModuleDefMD asmDef, string ReplaceURL)
        {
            foreach (TypeDef type in asmDef.Types)
            {
                if (type.Name == "pElid")
                {
                    foreach (MethodDef method in type.Methods)
                    {
                        if (method.Body != null)
                        {
                            for (int i = 0; i < method.Body.Instructions.Count(); i++)
                            {
                                if (method.Body.Instructions[i].OpCode == OpCodes.Ldstr)
                                {
                                    if (method.Body.Instructions[i].Operand.ToString() == "%UURRLL%")
                                    {
                                        method.Body.Instructions[i].Operand = ReplaceURL;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
