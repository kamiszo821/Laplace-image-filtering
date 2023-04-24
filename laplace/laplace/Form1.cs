using System.Windows.Forms.VisualStyles;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using CsDLL;
using System.Diagnostics;

namespace laplace
{
    delegate void LaplacianFilter(byte[] image, int width, int height, byte[] newImage);
    public partial class Form1 : Form
    {
        private string pathToBMP = "";
        private Bitmap input;
        private byte[] byteArray;
        private int threadDefault;
        private LaplacianFilter filterFunction;
        private byte[] result;

        public Form1()
        {
            InitializeComponent();

        }
        private void Form1_Load(object sender, EventArgs e)
        {
            threadDefault = Environment.ProcessorCount;
            this.pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            this.pictureBox2.SizeMode = PictureBoxSizeMode.Zoom;
            this.trackBar1.Value = threadDefault;
            this.textBox1.Text = threadDefault.ToString();
            this.filterButton.Enabled = false;
        }

        private void setByteArray()
        {
            this.input = new Bitmap(this.pathToBMP);    
            this.byteArray = new byte[input.Width* input.Height*3];
            this.result = new byte[input.Width * input.Height * 3];
            int pixelNo = 0;
            for (int y = 0; y < input.Height; y++)
            {
                for (int x = 0; x < input.Width; x++)
                {
                    Color pixelColor = input.GetPixel(x, y);
                    this.byteArray[pixelNo] = pixelColor.B;
                    this.byteArray[pixelNo+1] = pixelColor.G;
                    this.byteArray[pixelNo+2] = pixelColor.R;
                    pixelNo += 3;
                }
            }
        }
        private void setLibrary()
        {
            if (this.radioButton1.Checked)
            {
                [DllImport(@"D:\Nauka\korki\ja\laplace\x64\Debug\AsmDLL.dll")]
                static extern void laplacianFilterAsm(byte[] image, int width, int height, byte[] newImage);
                this.filterFunction = laplacianFilterAsm;
            }
            else if (this.radioButton2.Checked)
            {
                this.filterFunction = LaplacianFilterCs.laplacianFilterCs;
            }
        }

        void multiThreadFiltering(int threadNumber, byte[] image, int width, int height, byte[] newImage)
        {
            if (threadNumber > height)                                          // odczytanie iloœci w¹tków z suwaka
                threadNumber = height;
            int moduloHeight = height % threadNumber;                           // dzielenie wejœciowej tablicy w odpowiedni sposób dla w¹tków
            int subArrayHeight = (int)(height / threadNumber);
            byte[][] subArrays = new byte[threadNumber][];
            byte[][] filteredSubArrays = new byte[threadNumber][];
            int subArrayPosition = 0;
            List<Task> threads = new List<Task>();
            List<FilteringData> dataList = new List<FilteringData>();
            for (int y = 0; y < height - moduloHeight - 1; y += subArrayHeight)     // grafika jest dzielona w poziomie, na fragmenty obrazu o wysokoœci równej: (ca³kowita wysokoœæ obrazu)/iloœæ w¹tków
            {                                                                       // je¿eli wysokoœæ obrazu nie jest podzielna ca³kowicie przez iloœæ w¹tków to reszta jest równo dzielona na pocz¹tkowe w¹tki
                int startIndex = y;
                int endIndex = y + subArrayHeight;

                if (moduloHeight > 0)                                               // przydzielanie reszty z dzielenia wysokoœci do w¹tków
                {
                    endIndex += 1;
                    moduloHeight--;
                    y++;
                }
                if (startIndex > 0)
                    startIndex -= 1;
                if (endIndex < height)
                    endIndex += 1;

                subArrays[subArrayPosition] = new byte[endIndex * width * 3 - startIndex * width * 3];
                int tempArrayPosition = subArrayPosition;
                Array.Copy(image, startIndex * width * 3, subArrays[tempArrayPosition], 0, endIndex * width * 3 - startIndex * width * 3);
                filteredSubArrays[tempArrayPosition] = new byte[endIndex * width * 3 - startIndex * width * 3];
                FilteringData data = new FilteringData(subArrays[tempArrayPosition], width, endIndex - startIndex, filteredSubArrays[tempArrayPosition], filterFunction);
                threads.Add(Task.Factory.StartNew(data.laplace));                   // uruchamianie w¹tku
                dataList.Add(data);
                subArrayPosition++;
            }

            Task.WaitAll(threads.ToArray());                                        // czekanie na zakoñczenie pracy w¹tków

            int currentHeight = 0;
            foreach (var subImage in filteredSubArrays)
            {
                if (currentHeight == 0)
                {
                    Array.Copy(subImage, 0, newImage, currentHeight, subImage.Length - width * 3);
                    currentHeight += subImage.Length / (width * 3) - 1;
                }
                else
                {
                    Array.Copy(subImage, width * 3, newImage, currentHeight * width * 3, subImage.Length - width * 3);
                    currentHeight += subImage.Length / (width * 3) - 2;
                }
            }
            threads.Clear();
        }

        private void runFilter()
        {
            Stopwatch stopWatch = new Stopwatch();
            stopWatch.Start();
            this.multiThreadFiltering(this.trackBar1.Value, this.byteArray, this.input.Width, this.input.Height, this.result);
            stopWatch.Stop();
            timerLabel.Text = stopWatch.ElapsedMilliseconds.ToString() + " ms";
        }

        private void runAlgorithm()
        {
            this.setByteArray();
            this.setLibrary();
            this.runFilter();
        }

        private void updateWithFinished()
        {
            Bitmap resultBitmap = (Bitmap)this.input.Clone();
            int pixelNo = 0;
            for (int y = 0; y < input.Height; y++)
            {
                for (int x = 0; x < input.Width; x++)
                {
                    Color pixelColor = new();
                    pixelColor = Color.FromArgb(255, this.result[pixelNo+2], this.result[pixelNo + 1], this.result[pixelNo]);
                    resultBitmap.SetPixel(x, y, pixelColor);
                    pixelNo += 3;
                }
            }
            this.pictureBox2.Image = resultBitmap;
        }

        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            this.textBox1.Text = this.trackBar1.Value.ToString();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            try
            {
                int val = Int32.Parse(this.textBox1.Text);
                this.textBox1.ForeColor = Color.Black;
                if (val > 0 && val < 65)
                {
                    this.trackBar1.Value = val;
                }
                else if (val <=0)
                {
                    this.trackBar1.Value = 1;
                    this.textBox1.Text = "1";
                }
                else
                {
                    this.trackBar1.Value = 64;
                    this.textBox1.Text = "64";
                }
            }
            catch (Exception ex)
            {
                this.textBox1.ForeColor = Color.Red;
            }
        }

        private void textBox1_Leave(object sender, EventArgs e)
        {
            this.textBox1.Text = this.trackBar1.Value.ToString();
        }

        private void filterButton_Click(object sender, EventArgs e)
        {
            this.runAlgorithm();
            this.updateWithFinished();
        }

        private void importFileButton_Click(object sender, EventArgs e)
        {
            // odkomentuj w produkcji
            if (this.openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                pictureBox1.Image = Image.FromFile(this.openFileDialog1.FileName);
                this.pathToBMP = this.openFileDialog1.FileName;
                this.filterButton.Enabled = true;
            }
            //Wywal kod poni¿ej w produkcji.
            //pictureBox1.Image = Image.FromFile("D:\\Nauka\\korki\\ja\\sample_1920×1280.bmp");
            //this.pathToBMP = "D:\\Nauka\\korki\\ja\\sample_1920×1280.bmp";
            //this.filterButton.Enabled = true;
        }
    }
    class FilteringData                                 // klasa przechowuj¹ca dane potrzebne do filtrowania
    {
        private byte[] image;
        private int width;
        private int height;
        private byte[] filtered;
        private LaplacianFilter laplaceDelegate;

        public FilteringData(byte[] image, int width, int height, byte[] filtered, LaplacianFilter fun_delegate)
        {
            this.image = image;
            this.width = width;
            this.height = height;
            this.filtered = filtered;
            this.laplaceDelegate = fun_delegate;
        }

        public void laplace()
        {
            laplaceDelegate(this.image, this.width, this.height, this.filtered);
        }
    };
}