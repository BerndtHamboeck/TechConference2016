using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.Azure.Devices;
using Microsoft.Azure.Devices.Common.Exceptions;
using System.Diagnostics;

namespace IotHubCreateDevices
{
    public class IotHelper
    {

        static RegistryManager registryManager = null;
        static string connectionString = "{iothub connection string}";
        
        public  async static Task<string> AddDeviceAsync(string deviceId)
        {
            Device device;
            bool isNew = true;

            if(registryManager == null)
                registryManager = RegistryManager.CreateFromConnectionString(connectionString);
            
            try
            {
                device = await registryManager.AddDeviceAsync(new Device(deviceId));
            }
            catch (DeviceAlreadyExistsException)
            {
                device = await registryManager.GetDeviceAsync(deviceId);
                isNew = false;
            }

            if(isNew)
                Debug.WriteLine(string.Format("Generated device key: {0}", device.Authentication.SymmetricKey.PrimaryKey));
            else
                Debug.WriteLine(string.Format("Using existing device key: {0}", device.Authentication.SymmetricKey.PrimaryKey));

            return device.Authentication.SymmetricKey.PrimaryKey;

        }
    }
}
