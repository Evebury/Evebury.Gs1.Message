using Evebury.Gs1.Message.R3.Gpc;
using Evebury.Gs1.Message.Xml.Xsl;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml;
using System.Xml.Serialization;
using System.Xml.XPath;

namespace Evebury.Gs1.Message.Xsl
{
    internal class ResponseExtension : IXslExtension
    {
        public string NamespaceUri => @"urn:xsl:extension:gdsn:gs1:response";

        private const string UNDEFINED = "undefined";

        private XslResponse _response;
        private XslTransaction _transaction;
        private int _version;
        private readonly Dictionary<string, BrickPath> _bricks = [];

        private void Reset()
        {
            _response = null;
            _transaction = null;
            _version = 0;
        }

        internal void ClearBuffer() 
        {
            Reset();
            _bricks.Clear();
        }

        public void BeginResponse(string version)
        {
            _response = new();
            if (!string.IsNullOrEmpty(version))
            {
                if (version.Contains('.')) 
                {
                    _version = Convert.ToInt32(version.Split('.')[0]);
                }
                else 
                {
                    _version = Convert.ToInt32(version);
                }
            }
        }

        public XPathNavigator EndResponse()
        {
            if (_response == null) throw new InvalidOperationException();
            Response response = Response.GetResponse();

            List<Transaction> transactions = [];

            foreach (string transactionId in _response.Transactions.Keys)
            {
                Transaction transaction = Response.GetTransaction(transactionId, _response.GetEvents(transactionId));
                if (transaction.Status == TransactionStatusType.REJECTED)
                {
                    response.Status = StatusType.ERROR;
                }
                transactions.Add(transaction);
            }

            if (transactions.Count > 0)
            {
                response.Transactions = [.. transactions];
            }

            Reset();

            XmlDocument xd = new();
            using (System.IO.MemoryStream stream = new())
            {
                new XmlSerializer(typeof(Response)).Serialize(stream, response);
                stream.Position = 0;
                xd.Load(stream);
            }
            return xd.CreateNavigator();
        }

        public void BeginTransaction(string transactionId)
        {
            if (_response == null) throw new InvalidOperationException();

            if (string.IsNullOrWhiteSpace(transactionId)) transactionId = Guid.Empty.ToString();
            if (!_response.Transactions.TryGetValue(transactionId, out XslTransaction transaction))
            {
                transaction = new(transactionId);
                _response.Transactions.Add(transactionId, transaction);
            }
            _transaction = transaction;
            _transaction.BeginTransaction();
        }

        public void EndTransaction()
        {
            _transaction?.EndTransaction();
        }

        public void BeginSequence()
        {
            _transaction?.BeginSequence();
        }

        public void EndSequence()
        {
            _transaction?.EndSequence();
        }


        public void AddWarnEvent(string eventId)
        {
            AddEvent(eventId, EventLevel.WARN);
        }

        public void AddInfoEvent(string eventId)
        {
            AddEvent(eventId, EventLevel.INFO);
        }

        public void AddErrorEvent(string eventId)
        {
            AddEvent(eventId, EventLevel.ERROR);
        }

        public void AddExceptionEvent(string eventId, string message) 
        {
            if (_response == null) throw new InvalidOperationException();
            if (_transaction == null) BeginTransaction(Guid.Empty.ToString());
            _transaction.AddEvent(eventId, message, EventLevel.ERROR);
        }

        private void AddEvent(string eventId, EventLevel level)
        {
            if (_response == null) throw new InvalidOperationException();
            if (_transaction == null) BeginTransaction(Guid.Empty.ToString());
            string message = UNDEFINED;
            switch (_version)
            {
                case 3:
                    {
                        string value = R3.Resource.Message.ResourceManager.GetString(eventId, CultureInfo.InvariantCulture);
                        if (value != null) message = value;
                        break;
                    }
            }
            _transaction.AddEvent(eventId, message, level);
        }

        public void AddEventData(string key, string value)
        {
            AddEventDataWithLabel(key, value, null);
        }

        public void AddEventDataWithLabel(string key, string value, string label)
        {
            if (_transaction == null) BeginTransaction(Guid.Empty.ToString());
            _transaction.AddEventData(key, value, label, true);
        }

        public void AddSequenceEventData(string key, string value)
        {
            AddSequenceEventDataWithLabel(key, value, null);
        }

        public void AddSequenceEventDataWithLabel(string key, string value, string label)
        {
            if (_transaction == null) BeginTransaction(Guid.Empty.ToString());
            _transaction.AddEventData(key, value, label, false);
        }


        #region auxiliary
        /// <summary>
        /// Gets a boolean if timespan is invalid start &lt; end
        /// </summary>
        /// <param name="start"></param>
        /// <param name="end"></param>
        /// <returns></returns>
        public static bool InvalidDateTimeSpan(string start, string end)
        {
            if (DateTime.TryParse(start, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime startDate))
            {
                if (DateTime.TryParse(end, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime endDate))
                {
                    return endDate < startDate;
                }
            }
            return false;
        }

        public static string RandomId()
        {
            return Guid.NewGuid().ToString();   
        }

        public static string TimeStamp()
        {
            return DateTime.UtcNow.ToString("O");
        }

        public static string Today()
        {
            return DateTime.UtcNow.Date.ToString("O");
        }

        public static string AddMonths(string dateTime, int months)
        {
            if (DateTime.TryParse(dateTime, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime date))
            {
                date = date.AddMonths(months);
                return date.ToString("O");
            }
            return dateTime;
        }

        public static bool InvalidRange(string start, string end)
        {
            if (double.TryParse(start, out double startValue))
            {
                if (double.TryParse(end, out double endValue))
                {
                    return endValue < startValue;
                }
            }
            return false;
        }

        public static bool OverlappingDateTimeRange(object node) 
        {
            XPathNavigator navigator = GetXPathNavigator(node);
            if (navigator == null) return false;
           
            List<DateTimeSpan> ranges = [];
            XPathNodeIterator iterator = navigator.Select("*");
            while (iterator.MoveNext()) 
            {
                string start = iterator.Current.GetAttribute("Start", "");
                string end = iterator.Current.GetAttribute("End", "");
                if (DateTime.TryParse(start, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime startDate))
                {
                    if (DateTime.TryParse(end, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime endDate))
                    {
                        DateTimeSpan span = new(startDate, endDate);
                        if (ranges.Exists(e => e.Overlaps(span))) return true;
                        ranges.Add(span);
                    }
                }
            }
            return false;
        }

        private struct DateTimeSpan(DateTime start, DateTime end)
        {
            public DateTime Start { get; set; } = start;

            public DateTime End { get; set; } = end;

            public readonly bool Overlaps(DateTimeSpan other) 
            {
                return other.Start >= Start && other.End <= End;
            }
        }

        public static bool InvalidSequence(string sequence) 
        { 
            if(string.IsNullOrWhiteSpace(sequence)) return false;
            if (sequence.Contains('.')) 
            {
                string[] parts = sequence.Split('.');
                foreach (string part in parts)
                {
                    if (!int.TryParse(sequence, out int value)) return true;
                    if (value == 0) return true;
                }
            }
            else
            {
                if (!int.TryParse(sequence, out int value)) return true;
                if (value == 0) return true;
            }
            return false;
        }

        public bool InvalidBrick(string brick)
        {
            BrickPath path = GetBrickPath(brick);
            return path.Class == null;
        }

        public bool IsInClass(string brick, string @class) 
        {
            BrickPath path = GetBrickPath(brick);
            return path.Class == @class;
        }

        public bool IsInFamily(string brick, string family)
        {
            BrickPath path = GetBrickPath(brick);
            return family.Contains(path.Family);
        }


        public bool IsInSegment(string brick, string segment)
        {
            BrickPath path = GetBrickPath(brick);
            return path.Segment == segment;
        }

        private BrickPath GetBrickPath(string brick) 
        {
            brick = brick?.Trim();
            if(_bricks.TryGetValue(brick, out BrickPath brickPath)) return brickPath;
            BrickPath path = GpcSchema.GetBrickPath(brick);
            _bricks.Add(brick, path);
            return path;
        }

        public static bool InvalidGLN(string gln) 
        {
            return InvalidGTIN(gln, 13);
        }

        public static bool InvalidGTIN(string gtin, int length) 
        {
            if(string.IsNullOrEmpty(gtin)) return true;
            if(gtin.Length != length) return true;
            
            List<int> digits = [];
            for (int i = 0; i < length; i++) 
            {
                char @char = gtin[i];
                if (!char.IsDigit(@char)) return true;
                digits.Add(Convert.ToInt16($"{@char}"));
            }
            int sum = digits.Take(digits.Count - 1).Reverse().Select((t, i) => t * ((i % 2) > 0 ? 1 : 3)).Sum();
            int lastDigit = (sum % 10 > 0) ? 10 - sum % 10 : 0;
            return !(lastDigit == digits.Last());
        }

        #endregion


        #region data holders
        private class XslResponse
        {
            public Dictionary<string, XslTransaction> Transactions { get; set; } = [];

            public List<Event> GetEvents(string transactionId)
            {
                XslTransaction transaction = Transactions[transactionId];
                List<Event> events = [];
                foreach (XslEvent @event in transaction.Events)
                {
                    events.Add(@event.ToEvent());
                }
                return events;
            }
        }

        private class XslTransaction(string id)
        {
            public string Id { get; set; } = id;

            public List<XslEvent> Events { get; set; } = [];

            public List<EventData> EventData = [];

            public int SequenceId = 0;
            public List<EventData> Inline { get; set; } = [];

            public void BeginTransaction()
            {
                EventData.Clear();
                Inline.Clear();
            }

            public void EndTransaction()
            {
                EventData.Clear();
                Inline.Clear();
            }

            public void BeginSequence()
            {
                SequenceId++;
                EventData.Clear();
                Inline.Clear();
            }

            public void EndSequence()
            {
                EventData.Clear();
                Inline.Clear();
            }

            public void AddEventData(string key, string value, string label, bool isInline)
            {
                EventData eventData = new() { Key = key, Value = value, Sequence = SequenceId, SequenceSpecified = SequenceId > 0, Label = label };
                if (isInline)
                {
                    Inline.Add(eventData);
                }
                else
                {
                    if (!EventData.Exists(e => e.Key == eventData.Key && e.Value == eventData.Value))
                    {
                        EventData.Add(eventData);
                    }
                }
            }

            public void AddEvent(string eventId, string message, EventLevel level)
            {
                eventId = eventId?.Trim();
                if (string.IsNullOrEmpty(eventId)) eventId = UNDEFINED;

                message = message?.Trim();
                if (string.IsNullOrEmpty(message)) message = UNDEFINED;

                XslEvent @event = Events.Find(e => e.Id == eventId);
                if (@event == null)
                {
                    @event = new(eventId, message, level);
                    Events.Add(@event);
                }

                @event.Add(SequenceId, EventData);
                @event.Add(SequenceId, Inline);

                Inline.Clear();
            }

        }

        private class XslEvent(string id, string message, EventLevel level)
        {
            public string Id { get; set; } = id;
            public string Message { get; set; } = message;
            public EventLevel Level { get; set; } = level;
            public List<EventData> Data { get; set; } = [];

            public void Add(int sequence, List<EventData> eventData)
            {
                if (eventData.Count == 0) return;

                foreach (EventData data in eventData)
                {
                    data.Sequence = sequence;
                    data.SequenceSpecified = true;

                    if (!Data.Exists(e => e.Key == data.Key && e.Value == data.Value && e.Sequence == data.Sequence))
                    {
                        Data.Add(data);
                    }
                }
            }

            public Event ToEvent()
            {
                return Response.GetEvent(Id, Message, Level, Data);
            }
        }

        #endregion



        private static XPathNavigator GetXPathNavigator(object node)
        {
            if (node == null) return null;
            if (node is XPathNavigator navigator) return navigator;
            if (node is not XPathNodeIterator iterator) return null;
            if (iterator.Count == 0) return null;
            iterator.MoveNext();
            return iterator.Current;
        }
    }
}
