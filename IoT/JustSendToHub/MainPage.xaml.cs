using IotHubDeviceSender;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace JustSendToHub
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private bool _currentState = false;

        public MainPage()
        {
            this.InitializeComponent();
        }

        private void StartButton_Click(object sender, RoutedEventArgs e)
        {
            _currentState = true;

            //Send "standard" messages
            SendIotHubMessage();
            //Interactive Messages
            SendDeviceToCloudInteractiveMessage();
        }

        private void StopButton_Click(object sender, RoutedEventArgs e)
        {
            _currentState = false;
        }

        private async void SendIotHubMessage()
        {
            double avgWindSpeed = 10; // m/s
            Random rand = new Random();

            while (_currentState)
            {
                double currentWindSpeed = avgWindSpeed + rand.NextDouble() * 4 - 2;

                var messageString = await IotHelper.SendDeviceToCloudMessagesAsync("firstDevice", currentWindSpeed);
                InfoLabel.Text = string.Format("{0} > Sending message: {1}", DateTime.Now, messageString);

                await Task.Delay(TimeSpan.FromSeconds(1));
            }
        }

        private async void SendDeviceToCloudInteractiveMessage()
        {
            while (_currentState)
            {
                var messageString = await IotHelper.SendDeviceToCloudInteractiveMessagesAsync("firstDevice");
                InfoLabel.Text = string.Format("{0} > Sending interactive message: {1}", DateTime.Now, messageString);

                await Task.Delay(TimeSpan.FromSeconds(5));
            }
        }

    }
}
