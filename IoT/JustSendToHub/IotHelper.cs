using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.Azure.Devices.Client;
using Newtonsoft.Json;
using System.Threading;
using System.Diagnostics;

//NuGet Packages:
//Microsoft.Azure.Devices.Client
//JSON.Net

namespace IotHubDeviceSender
{
    class IotHelper
    {
        static DeviceClient deviceClient = null;
        static string iotHubUri = "{iot hub hostname}";
        static string deviceKey = "{device key}";

        //static string connectionString =
        //        "HostName=<yourhost>.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=<yourkey>";

        /// <summary>
        /// send a message to the azure iot hub
        /// </summary>
        /// <param name="deviceId"></param>
        /// <param name="currentWindSpeed"></param>
        public static async Task<string> SendDeviceToCloudMessagesAsync(string deviceId, double currentWindSpeed)
        {
            if (deviceClient == null)
            {
                //deviceClient = DeviceClient.CreateFromConnectionString(connectionString, deviceId);
                var authMethod = new DeviceAuthenticationWithRegistrySymmetricKey(deviceId, deviceKey);

                //amqp not supported in universal app -> https://github.com/Azure/azure-iot-sdks/blob/master/doc/faq.md
                deviceClient = DeviceClient.Create(iotHubUri, authMethod, TransportType.Http1);
            }

            var telemetryDataPoint = new
            {
                deviceId = deviceId,
                windSpeed = currentWindSpeed
            };

            var messageString = JsonConvert.SerializeObject(telemetryDataPoint);
            var message = new Message(Encoding.ASCII.GetBytes(messageString));

            await deviceClient.SendEventAsync(message);

            return messageString;
        }


        public static async Task<string> SendDeviceToCloudInteractiveMessagesAsync(string deviceId)
        {

            if (deviceClient == null)
            {
                //deviceClient = DeviceClient.CreateFromConnectionString(connectionString, deviceId);
                var authMethod = new DeviceAuthenticationWithRegistrySymmetricKey(deviceId, deviceKey);

                //amqp not supported in universal app -> https://github.com/Azure/azure-iot-sdks/blob/master/doc/faq.md
                deviceClient = DeviceClient.Create(iotHubUri, authMethod, TransportType.Http1);
            }

            var interactiveMessageString = "Alert message!";
            var interactiveMessage = new Message(Encoding.ASCII.GetBytes(interactiveMessageString));
            interactiveMessage.Properties["messageType"] = "interactive";
            interactiveMessage.MessageId = Guid.NewGuid().ToString();

            await deviceClient.SendEventAsync(interactiveMessage);
            return interactiveMessageString;
        }
    }
}
