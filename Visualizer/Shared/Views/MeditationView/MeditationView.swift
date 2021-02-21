//
//  MeditationView.swift
//  Visualizer
//
//  Created by Katalin Neda on 19/02/2021.
//

import SwiftUI
import AVFoundation

struct MeditationView: View {
    
    private var intend: Intend
    private let onSelectDone: (() -> Void)?
    private var audioPlayer: AVAudioPlayer?

    @State private var scale: CGFloat = 1
    @State private var scalePolygon: CGFloat = 1
    @State private var offset = CGSize.zero
    @State private var speed: TimeInterval = 0
    @State private var didStart = false
    
    init(intend: Intend, onSelectDone: (() -> Void)?) {
        self.intend = intend
        self.onSelectDone = onSelectDone
        if let path = Bundle.main.path(forResource: "music_zapsplat_among_the_stars", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            } catch {
                print("error")
            }
        }
    }

    var body: some View {
        ZStack {
            GradientBackgroundView(colors: intend.gradients)
                .ignoresSafeArea()
            VStack(alignment: .center) {
                HStack {
                    if didStart {
                        TimerView(animation: intend) {
                          updateSpeed()
                        }
                    }
                    Spacer()
                    Button(action: {
                        onSelectDone?()
                    }) {
                        Text(Strings.imBetter)
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                            .font(.body)
                    }
                    .frame(width: 120, height: 30)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.16), radius: 16, x: 0, y: 16)
                }
                .padding(EdgeInsets(top: 24, leading: 48, bottom: 24, trailing: 48))
                Spacer()
                ZStack {
                    ForEach((1 ..< intend.layers).reversed(), id: \.self) { number in
                        Polygon(width: CGFloat(intend.polygonBaseSize * number), height: CGFloat(intend.polygonBaseSize * number), speed: speed)
                            .scaleEffect(scale)
                            .rotation3DEffect(.degrees(scale == 1 ? 180 : 45), axis: (x: 0, y: 0, z: 1))
                            .foregroundColor(intend.mainColor)
                    }
                }
                .scaleEffect(scalePolygon)
                .offset(x: offset.width, y: offset.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                                self.offset = gesture.translation
                                self.scalePolygon = 0.3
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
                                self.offset = .zero
                                self.scalePolygon = 1
                            }
                        }
                )
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        withAnimation() {
                            self.scalePolygon = value.magnitude
                        }
                    }
                    .onEnded { _  in
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
                            self.scalePolygon = 1
                        }
                    }
                )
                Spacer()
            }
            .blur(radius: didStart ? 0 : 40)
            GradientBackgroundView(colors: [Color.white.opacity(0.3)])
                .ignoresSafeArea()
                .opacity(didStart ? 0 : 1)
                .animation(.easeIn)
            Text(Strings.yourExperienceIsAboutToStart)
                .foregroundColor(.white)
                .fontWeight(.heavy)
                .font(.system(size: 21))
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                .opacity(didStart ? 0 : 1)
                .animation(.easeIn)
        }
        .onAppear {
            playSound()
            speed = 100
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                speed = intend.defaultSpeed
                didStart = true
            }
            let animation = Animation.easeInOut(duration: intend.defaultSpeed).repeatForever(autoreverses: true)
            withAnimation(animation) {
                scale = 0.5
            }
        }
        .onDisappear {
            audioPlayer?.stop()
        }
    }
    
    // MARK: - Methods
    
    private func playSound() {
        audioPlayer?.play()
        audioPlayer?.numberOfLoops = 3
    }
    
    private func updateSpeed() {
        switch intend {
        case .mindDistraction:
            speed = intend.minMaxSpeed
        case .chillOut:
            speed = intend.defaultSpeed
        default:
            if speed - 0.5 != intend.minMaxSpeed {
                speed -= 0.5
            }
        }
    }
}
