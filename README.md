#PageAlignedArray

`PageAlignedArray` is a Swift class that implements a version of the built-in Swift array, but with guaranteed page-aligned storage buffers.
This is useful for iOS/macOS applications that use the Metal API. If you have large buffers with vertexes or any other data that changes between frames, it is highly recommended that you load that data to the GPU using shared memory (between the CPU and the GPU). Unfortunately, allocating page-aligned memory and managing its contents in Swift can be a pain. 

For this reason I've created `PageAlignedArray`. It makes it a breeze to create and manipulate an array containing any data type, and then turn into a shared-memory Metal buffer. Here's a quick code sample:
```
   var alignedArray : PageAlignedContiguousArray<matrix_double4x4> = [matrixTest, matrixTest]
   alignedArray.append(item)
   alignedArray.removeFirst() // Behaves just like a built-in array, with all convenience methods
    
   // When it's time to generate a Metal buffer:
   let device = MTLCreateSystemDefaultDevice()
   let testMetalBuffer = device?.makeBufferWithPageAlignedArray(alignedArray)

   // Of course, because we're in shared memory, we can continue to manipulate the contents of the 
   // array after generating the buffer and the GPU sees the latest data.  
```

**NOTE:** While it is safe to mutate the contents of the array after generating a buffer, keep in mind that you must generate a new buffer each time the length of the array changes, otherwise Metal won't know the array's new length.

##Suitable for large datasets
Because of the page-alignment constraint, `PageAlignedArray` has a minimum allocation size of one page, which translates to 16Kb on most iOS devices. This means that it is mostly suitable for larger, 100Kb+ datasets. Smaller datasets will cause significant memory waste with negligible performance benefits. 
