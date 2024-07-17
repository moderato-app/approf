/*
 Copyright © 2024 Apple Inc.

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SwiftUI

@available(macOS 15.0, *)
#Preview("Ripple") {
  RPView()
}

@available(macOS 15.0, *)
struct RPView: View {
  @State var counter: Int = 0
  @State var origin: CGPoint = .zero

  var body: some View {
    VStack {
      Spacer()

      Image("About")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .modifier(RippleEffect(at: origin, trigger: counter))

      Spacer()
    }
    .padding()
  }
}

struct PushEffect<T: Equatable>: ViewModifier {
  var trigger: T

  func body(content: Content) -> some View {
    content.keyframeAnimator(
      initialValue: 1.0,
      trigger: trigger
    ) { view, value in
      view.visualEffect { view, _ in
        view.scaleEffect(value)
      }
    } keyframes: { _ in
      SpringKeyframe(0.95, duration: 0.2, spring: .snappy)
      SpringKeyframe(1.0, duration: 0.2, spring: .bouncy)
    }
  }
}

/// A modifer that performs a ripple effect to its content whenever its
/// trigger value changes.
struct RippleEffect<T: Equatable>: ViewModifier {
  var origin: CGPoint

  var trigger: T

  init(at origin: CGPoint, trigger: T) {
    self.origin = origin
    self.trigger = trigger
  }

  func body(content: Content) -> some View {
    let origin = origin
    let duration = duration

    content.keyframeAnimator(
      initialValue: 0,
      trigger: trigger
    ) { view, elapsedTime in
      view.modifier(RippleModifier(
        origin: origin,
        elapsedTime: elapsedTime,
        duration: duration
      ))
    } keyframes: { _ in
      MoveKeyframe(0)
      LinearKeyframe(duration, duration: duration)
    }
  }

  var duration: TimeInterval { 3 }
}

/// A modifier that applies a ripple effect to its content.
struct RippleModifier: ViewModifier {
  var origin: CGPoint

  var elapsedTime: TimeInterval

  var duration: TimeInterval

  var amplitude: Double = 12
  var frequency: Double = 15
  var decay: Double = 8
  var speed: Double = 1200

  func body(content: Content) -> some View {
    let shader = ShaderLibrary.Ripple(
      .float2(origin),
      .float(elapsedTime),

      // Parameters
      .float(amplitude),
      .float(frequency),
      .float(decay),
      .float(speed)
    )

    let maxSampleOffset = maxSampleOffset
    let elapsedTime = elapsedTime
    let duration = duration

    content.visualEffect { view, _ in
      view.layerEffect(
        shader,
        maxSampleOffset: maxSampleOffset,
        isEnabled: elapsedTime > 0 && elapsedTime < duration
      )
    }
  }

  var maxSampleOffset: CGSize {
    CGSize(width: amplitude, height: amplitude)
  }
}
