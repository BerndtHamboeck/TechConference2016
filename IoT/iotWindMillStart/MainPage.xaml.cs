using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

using Windows.Devices.Gpio;
using Windows.UI.Core;
using System.Threading.Tasks;
using IotHubDeviceSender;

namespace iotWindMillDevice
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {

        private const int LED_PIN = 12;
        private GpioPin pin;
        private GpioPinValue _currentState = GpioPinValue.High;

        public MainPage()
        {
            this.InitializeComponent();

            //InitGPIO();
            SendIotHubMessage(true);

            SendDeviceToCloudInteractiveMessage(true);
        }


        private void OnButton_Click(object sender, RoutedEventArgs e)
        {
            pin.Write(GpioPinValue.Low);


        }

        private void OffButton_Click(object sender, RoutedEventArgs e)
        {
            pin.Write(GpioPinValue.High);

        }



        private async void InitGPIO()
        {
            var gpio = GpioController.GetDefault();

            if (gpio == null)
            {
                pin = null;
                return;
            }

            pin = gpio.OpenPin(LED_PIN);

            if (pin == null)
            {
                return;
            }
            pin.ValueChanged += Pin_ValueChanged;
            pin.Write(GpioPinValue.High);
            pin.SetDriveMode(GpioPinDriveMode.Output);
        }


        private async void SendIotHubMessage(bool debug = false)
        {
            double avgWindSpeed = 10; // m/s
            Random rand = new Random();

            while (_currentState == GpioPinValue.Low || debug)
            {
                double currentWindSpeed = avgWindSpeed + rand.NextDouble() * 4 - 2;

                var messageString = await IotHelper.SendDeviceToCloudMessagesAsync("firstDevice", currentWindSpeed);
                InfoLabel.Text = string.Format("{0} > Sending message: {1}", DateTime.Now, messageString);

                await Task.Delay(TimeSpan.FromSeconds(1));
            }
        }

        private async void SendDeviceToCloudInteractiveMessage(bool debug = false)
        {
            while (_currentState == GpioPinValue.Low || debug)
            {
                var messageString = await IotHelper.SendDeviceToCloudInteractiveMessagesAsync("firstDevice");
                InfoLabel.Text = string.Format("{0} > Sending interactive message: {1}", DateTime.Now, messageString);

                await Task.Delay(TimeSpan.FromSeconds(5));
            }
        }

        private void Pin_ValueChanged(GpioPin sender, GpioPinValueChangedEventArgs args)
        {
            var task = Dispatcher.RunAsync(CoreDispatcherPriority.Normal, () =>
            {
                _currentState = pin.Read();
                InfoLabel.Text =  _currentState == GpioPinValue.High ? "Stopped" : "Running";

                if(_currentState == GpioPinValue.Low)
                    SendIotHubMessage();

            });
        }



    }
}
