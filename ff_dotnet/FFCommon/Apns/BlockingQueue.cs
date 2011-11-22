using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Collections;

namespace FFCommon.Apns
{
    public class BlockingQueue<T> : IEnumerable<T> where T : class
    {
        private int _count = 0;
        private Queue<T> _queue = new Queue<T>();

        public T Dequeue()
        {
            lock (_queue)
            {
                while (_count <= 0) Monitor.Wait(_queue);
                _count--;
                return _queue.Dequeue();
            }
        }

        public void Enqueue(T data)
        {
            lock (_queue)
            {
                _queue.Enqueue(data);
                _count++;
                Monitor.Pulse(_queue);
            }
        }

        public T Peek()
        {
            lock (_queue)
            {
                return _queue.Peek();
            }
        }

        public int Count
        {
            get
            {
                return _count;
            }
        }

        IEnumerator<T> IEnumerable<T>.GetEnumerator()
        {
            while (true) yield return Dequeue();
        }


        IEnumerator IEnumerable.GetEnumerator()
        {
            return ((IEnumerable<T>)this).GetEnumerator();
        }
    }

}
