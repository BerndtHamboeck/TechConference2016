using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace TitanicRClient
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {

            List<string> sps = new List<string>();
            List<Image> images = new List<Image>();
            sps.Add("Survival_by_Age1"); //"get_titanic_plot2"
            images.Add(imageSurvival_by_Age1);
            sps.Add("Survival_by_Age2");
            images.Add(imageSurvival_by_Age2);

            sps.Add("Survival_by_Class");
            images.Add(imageSurvival_by_Class);

            sps.Add("Survival_by_Embarked");
            images.Add(imageSurvival_by_Embarked);

            sps.Add("Survival_by_Fare");
            images.Add(imageSurvival_by_Fare);

            sps.Add("Survival_by_Gender");
            images.Add(imageSurvival_by_Gender);

            sps.Add("Survival_by_Parch");
            images.Add(imageSurvival_by_Parch);

            sps.Add("Survival_by_SibSp");
            images.Add(imageSurvival_by_SibSp);

            sps.Add("Survival_by_Ticket");
            images.Add(imageSurvival_by_Ticket);

            var connString = "Data Source= .;Initial Catalog=IntegrateR;Integrated Security=True";
            using (SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            {
                conn.Open();
                SqlCommand cmd = conn.CreateCommand();
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                for (int i = 0; i < sps.Count; i++)
                {
                    try
                    {
                        cmd.CommandText = sps[i];

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {

                            if (dr.Read())
                            {
                                var img = dr.GetValue(0) as byte[];

                                #region read the image from a bytes array

                                System.IO.MemoryStream ms = new System.IO.MemoryStream(img);
                                ms.Seek(0, System.IO.SeekOrigin.Begin);

                                BitmapImage newBitmapImage = new BitmapImage();
                                newBitmapImage.BeginInit();
                                newBitmapImage.StreamSource = ms;
                                newBitmapImage.EndInit();
                                images[i].Source = newBitmapImage;

                                #endregion
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        throw;
                    }
                }
            }
        }
    }
}
