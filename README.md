Image provider with GCD implementation 

Implementation details 
1. Download image asynchronously
2. Save image in cache
3. Preventing race condition


Caching images can make the table and collection views in app instantiate fast and respond quickly to scrolling. 

The class ImageProvider.swift demonstrates a basic mechanism for image loading from a URL with URLSession and caching the downloaded images using NSCache.

As the user scrolls in a view (table view or collection view), the app requests the same image repeatedly. ImageProvider holds pendingResponses to store the relevant completion blocks until the image loads, then passes the image to all of the requesting blocks so the API only has to make one call to fetch an image for a given URL.

While operating on pendingResponses we can run into race condition. A race condition happens when two or more threads access a shared data and change it's value at the same time and can lead to a crash or data corruption.

To deal with race condition, we are going to add an queue that uses the barrier flag. This flag allows any outstanding tasks on the queue to finish, but blocks any further tasks from executing until the barrier task is completed.


