using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CsDLL
{
    public class LaplacianFilterCs
    {
        public static void laplacianFilterCs(byte[] image, int width, int height, byte[] filteredImage)
        {
            int[] MASK = new int[] { 1, 1, 1, 1, -8, 1, 1, 1, 1 };
            for (int y = 1; y < height - 1; y++)                        // pętla po wartościach Y obrazu
            {
                for (int x = 3; x < width * 3 - 3; x += 3)              // pętla po wartościach X obrazu, uwzględniając, że każdy piksel posiada trzy wartości R,G,B
                {
                    int RedSum = 0;
                    int GreenSum = 0;
                    int BlueSum = 0;
                    int idMask = 0;
                    for (int pxY = -1; pxY <= 1; pxY++)                 //
                    {                                                   // pętle otaczające dookoła piksel, dla którego jest aktualnie wyznaczana nowa wartość
                        for (int pxX = -1; pxX <= 1; pxX++)             //
                        {
                            int r = image[(y - pxY) * width * 3 + x + pxX * 3 + 2] * MASK[idMask];
                            RedSum += r;       // nałożenie maski na każdy kolor
                            int g = image[(y - pxY) * width * 3 + x + pxX * 3 + 1] * MASK[idMask];
                            GreenSum += g;     // i dodanie do odpowiedniej sumy
                            int b = image[(y - pxY) * width * 3 + x + pxX * 3 + 0] * MASK[idMask];
                            BlueSum += b;      // 
                            idMask++;
                        }
                    }                                                           // sposób wybierania pozycji:
                                                                                // wybór rzędu: (odpowiedni rząd Y - przesunięcie względem środkowego piksela) * szerokość obrazka * 3(RGB)
                    RedSum = (RedSum < 0) ? 0 : (RedSum > 255) ? 255 : RedSum;
                    GreenSum = (GreenSum < 0) ? 0 : (GreenSum > 255) ? 255 : GreenSum;
                    BlueSum = (BlueSum < 0) ? 0 : (BlueSum > 255) ? 255 : BlueSum;

                    filteredImage[y * width * 3 + x + 2] = (byte)RedSum;               // zapisanie nowych wartości
                    filteredImage[y * width * 3 + x + 1] = (byte)GreenSum;
                    filteredImage[y * width * 3 + x + 0] = (byte)BlueSum;
                }
            }
        }
    }
}
