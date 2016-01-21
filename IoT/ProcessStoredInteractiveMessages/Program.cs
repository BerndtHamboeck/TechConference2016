using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

//NuGet: WindowsAzure.ServiceBus

using System.IO;
using Microsoft.ServiceBus.Messaging;

namespace ProcessStoredDeviceToCloudMessages
{
    class Program
    {
        static string connectionString = "{service bus listen connection string}";
        static string queueName = "softdatiot"; // azure portal -> service bus -> queues (Warteschlangen) tab

        static void Main(string[] args)
        {
            Console.WriteLine("Process Interactive Messages from Service Bus app\n");

            QueueClient Client = QueueClient.CreateFromConnectionString(connectionString, queueName);

            OnMessageOptions options = new OnMessageOptions();
            options.AutoComplete = false;
            options.AutoRenewTimeout = TimeSpan.FromMinutes(1);

            Client.OnMessage((message) =>
            {
                try
                {
                    var bodyStream = message.GetBody<Stream>();
                    bodyStream.Position = 0;
                    var bodyAsString = new StreamReader(bodyStream, Encoding.ASCII).ReadToEnd();

                    Console.WriteLine("Received message: {0} messageId: {1}", bodyAsString, message.MessageId);

                    message.Complete();
                }
                catch (Exception)
                {
                    message.Abandon();
                }
            }, options);

            Console.WriteLine("Receiving interactive messages from SB queue...");
            Console.WriteLine("Press any key to exit.");
            Console.ReadLine();
        }
    }
}
