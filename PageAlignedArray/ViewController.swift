//    Copyright (c) 2016, Eldad Eilam
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification, are
//    permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//       conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//       of conditions and the following disclaimer in the documentation and/or other materials
//       provided with the distribution.
//
//    3. Neither the name of the copyright holder nor the names of its contributors may be used
//       to endorse or promote products derived from this software without specific prior written
//       permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//    OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
//    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
//    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import UIKit
import Metal
import MetalKit

extension vector_double4 {
    static func == (lhs: vector_double4, rhs: vector_double4) -> Bool {
        if lhs.w == rhs.w && lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z {
            return true
        } else {
            return false
        }
    }
}

extension matrix_double4x4 {
    static func == (lhs: matrix_double4x4, rhs: matrix_double4x4) -> Bool {
        if lhs.columns.0 == rhs.columns.0 &&
            lhs.columns.1 == rhs.columns.1 &&
            lhs.columns.2 == rhs.columns.2 &&
            lhs.columns.3 == rhs.columns.3 {
            return true
        } else {
            return false
        }
    }

    static func != (lhs: matrix_double4x4, rhs: matrix_double4x4) -> Bool {
        return lhs == rhs ? false : true
    }

}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let testVector = vector_double4(0, 1, 2, 3)
        var matrixTest = matrix_double4x4.init(columns: (testVector, testVector, testVector, testVector))

        var alignedArrayEmpty : PageAlignedContiguousArray<matrix_double4x4>
        var alignedArrayInitializer = PageAlignedContiguousArray<matrix_double4x4>(repeating: matrixTest, count: 4096)
        var alignedArrayLiteral : PageAlignedContiguousArray<matrix_double4x4> = [matrixTest, matrixTest]
        
        var current = 0.0
        for (index, _) in alignedArrayInitializer.enumerated() {
			alignedArrayInitializer[index] = matrix_double4x4.init(columns: (vector_double4(repeating: current), vector_double4(repeating: current), vector_double4(repeating: current), vector_double4(repeating: current)))
            current += 1.0
        }
        
        current = 0.0
        repeat {
			matrixTest.columns = (vector_double4(repeating: current), vector_double4(repeating: current), vector_double4(repeating: current), vector_double4(repeating: current))

            let currentMat = alignedArrayInitializer.first
            if currentMat! != matrixTest {
                print ("error")
            }
            current += 1.0
            alignedArrayInitializer.removeFirst()
        } while (alignedArrayInitializer.count != 0)
        
        let device = MTLCreateSystemDefaultDevice()
        let testMetalBuffer = device?.makeBufferWithPageAlignedArray(alignedArrayInitializer)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

