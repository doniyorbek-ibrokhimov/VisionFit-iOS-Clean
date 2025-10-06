//
//  ProfileView.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 21/12/24.
//

import SwiftUI
import Charts

// Mock data for charts
struct WeightData: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    
    init(day: Int, weight: Double) {
        let calendar = Calendar.current
        self.date = calendar.date(byAdding: .day, value: -day, to: Date()) ?? Date()
        self.weight = weight
    }
}

struct ProfileView: View {
    // Colors
    let greenColor = Color(hex: "BBF246")
    let tabBarColor = Color(hex: "192126")
    
    // Time period selection
    @State private var selectedTimePeriod = 0
    let timePeriods = ["1 Day", "1 Month", "1 Year", "Max"]
    
    // Selected program
    @State private var selectedProgram = 0
    let programs = [
        (icon: "figure.run", name: "Jog"),
        (icon: "figure.yoga", name: "Yoga"),
        (icon: "figure.outdoor.cycle", name: "Cycling"),
        (icon: "dumbbell.fill", name: "Workout")
    ]
    
    // Mock data
    let weightData: [WeightData] = [
        WeightData(day: 6, weight: 75.3),
        WeightData(day: 5, weight: 75.8),
        WeightData(day: 4, weight: 75.1),
        WeightData(day: 3, weight: 76.0),
        WeightData(day: 2, weight: 75.6),
        WeightData(day: 1, weight: 75.2),
        WeightData(day: 0, weight: 74.8)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Profile
            HStack(alignment: .center) {
                // Profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back!!!")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Khusan Rakhmatullayev")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding()
            
            // Workout Progress Card
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(tabBarColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Workout Progress !")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("14 Exercise left")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Progress Circle
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(greenColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                        
                        Text("75%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .frame(height: 80)
            .padding(.horizontal)
            
            // Metrics Buttons
            HStack(spacing: 12) {
                metricButton(title: "Weight", isSelected: true)
                metricButton(title: "Height", isSelected: false)
                metricButton(title: "Calories", isSelected: false)
            }
            .padding(.top, 16)
            .padding(.horizontal)
            
            // Graph View with Swift Charts
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(tabBarColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                VStack {
                    Spacer()
                    
                    // Chart
                    Chart(weightData) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.weight)
                        )
                        .foregroundStyle(greenColor)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.weight)
                        )
                        .foregroundStyle(greenColor)
                    }
                    .chartYScale(domain: 74...77)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.weekday(.abbreviated))
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisValueLabel {
                                if let weight = value.as(Double.self) {
                                    Text("\(weight, specifier: "%.1f") kg")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .frame(height: 180)
                    .padding(.horizontal)
                    
                    // Period selector
                    HStack {
                        ForEach(0..<timePeriods.count, id: \.self) { index in
                            Button(action: {
                                selectedTimePeriod = index
                            }) {
                                Text(timePeriods[index])
                                    .font(.system(size: 14, weight: selectedTimePeriod == index ? .medium : .regular))
                                    .foregroundColor(selectedTimePeriod == index ? .black : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedTimePeriod == index ? Color.white : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.bottom, 10)
                }
                .padding()
            }
            .frame(height: 270)
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Programs Section
            VStack(alignment: .leading) {
                Text("Programs")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Program Buttons
                HStack(spacing: 16) {
                    ForEach(0..<programs.count, id: \.self) { index in
                        programButton(
                            icon: programs[index].icon,
                            name: programs[index].name,
                            isSelected: selectedProgram == index
                        ) {
                            selectedProgram = index
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .background(Color.white)
    }
    
    // Helper Views
    private func metricButton(title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? greenColor : tabBarColor)
            .cornerRadius(16)
    }
    
    private func programButton(icon: String, name: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? greenColor : tabBarColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .black : .white)
                }
                
                Text(name)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
        }
    }
}
