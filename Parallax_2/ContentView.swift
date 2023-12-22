//
//  ContentView.swift
//  Parallax_2
//
//  Created by Prathamesh on 21/12/23.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    private let motionManger = CMMotionManager()
    private let queue = OperationQueue()
    @State var yAngle: Double = 0.0
    @State private var selectedSegment = 0
       let segments = ["Drag", "Gyro"]
    
    @State var offset: CGSize = .zero
    var body: some View {
        ZStack{
            Color.white
            VStack{
                Spacer()
                VStack {
                    Image("Goldfish")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250,height: 200)
                        .foregroundStyle(.tint)
                        .padding()
                        .offset(x:offset2Angle().degrees * 2,y: offset2Angle(true).degrees * 2)
                }
                .background{
                    ZStack{
                        Color.black
                        VStack(alignment: .leading){
                            
                            Circle()
                                .foregroundColor(.yellow)
                                .scaleEffect(1.2,anchor: .leading)
                                .offset(x: 75,y: -80)
                            Text("Gold-Fish")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .padding(.bottom,10)
                                .padding(.leading,10)
                        }
                        
                    }
                    .frame(width: 225,height: 350)
                    .cornerRadius(15)
                }
                .shadow(color: .black.opacity(0.5), radius: 10,y: 10)
                .rotation3DEffect(offset2Angle(true),
                                  axis: (x: -1.0, y: 0.0, z: 0.0)
                )
                .rotation3DEffect(offset2Angle(),
                                  axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .rotation3DEffect(offset2Angle(true) * 0.1,
                                  axis: (x: 0.0, y: 0.0, z: 1.0)
                )
                //
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            
                            if selectedSegment == 0{
                                offset = value.translation
                                print(offset,": offset")
                            }
                            })
                    
                        .onEnded({ _ in
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction:
                                                                0.32, blendDuration: 0.32)){
                                if selectedSegment == 0{
                                    offset = .zero
                                }
                            }
                        })
                )
                
                Spacer()
                Picker(selection: $selectedSegment, label: Text("Segments")) {
                                ForEach(0..<segments.count) { index in
                                    Text(self.segments[index]).tag(index)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal,30)
                            .onChange(of: selectedSegment) { newValue in
                                            // Perform action based on the selected segment
                                            print("Selected Segment: \(segments[newValue])")
                                            
                                if selectedSegment == 1{
                                    initializeMotionManager()
                                }
                                else{
                                    motionManger.stopGyroUpdates()
                                    motionManger.stopAccelerometerUpdates()
                                    motionManger.stopDeviceMotionUpdates()
                                    
                                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction:
                                                                        0.32, blendDuration: 0.32)){
                                        offset = .zero
                                    }
                                }
                                        }
                Spacer()
            }
        }
        .onAppear(){
//            initializeMotionManager()
        }
        .onDisappear(){
            motionManger.stopGyroUpdates()
            motionManger.stopAccelerometerUpdates()
            motionManger.stopDeviceMotionUpdates()
        }
    }
    
    func offset2Angle(_ isVertical: Bool = false)->Angle{
        let progress = (isVertical ? offset.height : offset.width)/(isVertical ? screenSize.height : screenSize.width)
        return .init(degrees: progress * 15)
    }
    
    var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else{
            return .zero
        }
        return window.screen.bounds.size
    }()
    
    
    private func initializeMotionManager() {
        let oneEightyByPiDouble: Double = 180.0 / Double.pi
        if !motionManger.isGyroAvailable // || !motionManger.isGyroActive
        {
            //            writeDataToCsv(str: "gyro available = \(motionManger.isGyroAvailable) , gyro active \(motionManger.isGyroActive)")
            return
        }
        
        motionManger.deviceMotionUpdateInterval = 0.01
        
        motionManger.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xMagneticNorthZVertical, to: queue, withHandler: { _deviceManager, _ in
            
            guard let deviceManager = _deviceManager else {
                return
            }
            
            let quaternion = deviceManager.attitude.quaternion
            let pitch = Float(deviceManager.attitude.pitch / 1.5)
            // let roll = deviceManager.attitude.roll
            // let yaw = deviceManager.attitude.yaw
            
            let x = quaternion.w * quaternion.x + quaternion.y * quaternion.z
            let y = quaternion.x * quaternion.x + quaternion.y * quaternion.y
            
            let xAngle = atan2(2 * x, 1 - 2 * y) * oneEightyByPiDouble
            let v = quaternion.w * quaternion.y - quaternion.z * quaternion.x
            self.yAngle = asin(2 * v) * oneEightyByPiDouble
            print(yAngle,": YAnagle",xAngle,": XAngle")
            offset = CGSize(width: yAngle * 10,height: xAngle * 10)
        })
    }
}

#Preview {
    ContentView()
}




