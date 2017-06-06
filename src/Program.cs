using System;
using System.Threading;

namespace src
{
    class Program
    {
        static void Main(string[] args)
        {
            for (int i = 0; i < 60; i++)
            {
                Console.WriteLine($"{i:00} - Hello World!");
                Thread.Sleep(1000);
            }
        }
    }
}
