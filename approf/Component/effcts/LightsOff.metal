#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[stitchable]] half4 lightsOff(float2 pos, half4 color){
   return 1 - color;
}
