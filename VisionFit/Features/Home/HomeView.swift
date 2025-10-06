//
//  HomeView.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/12/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedExercise: ExerciseType?
    @State private var currentExercise: ExerciseType?
    @State private var showVoiceStream = false
    @StateObject private var vm = ViewModel()
    @StateObject private var chatVM: ChatViewModel = ChatViewModel()
    @Namespace private var namespace

    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primaryDark)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.primaryDark.opacity(0.2))
    }

    var body: some View {
        homeContent
            .onChange(of: vm.selectedMetric, { _, newValue in
                vm.getMetricData(type: newValue)
            })
            .task {
                vm.getMetricData(type: vm.selectedMetric)
            }
            .navigationDestination(item: $selectedExercise) { exercise in
                ExerciseTrackerView(exerciseType: exercise)
                    .navigationTransition(
                        .zoom(sourceID: "exercise", in: namespace)
                    )
            }
            .navigationDestination(isPresented: $showVoiceStream) {
                VoiceStreamView()
                    .navigationTransition(
                        .zoom(sourceID: "voice", in: namespace)
                    )
            }
            .navigationBarBackButtonHidden()
            .environmentObject(vm)
    }

    private var homeContent: some View {
        VStack(spacing: 16) {
            // profile content
            HStack {
//                Image(systemName: "person")
                Image(.avatar)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 50, height: 50)

                Text("Khusan Rakhmatullayev")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            .matchedTransitionSource(id: "voice", in: namespace)
//            .onTapGesture {
//                withAnimation(.easeInOut) {
//                    showVoiceStream = true
//                }
//            }
            
            

            // Metrics
            HStack {
                ForEach(Metric.allCases) { metric in
                    metricButton(for: metric)
                }
            }

            // Metrics Graphs
//            switch vm.selectedMetric {
//            case .weight:
//                ChartView(data: vm.weightData, type: .weight)
//            case .height:
//                ChartView(data: vm.heightData, type: .height)
//            case .calories:
//                ChartView(data: vm.caloriesData, type: .calories)
//            case .bmi:
//                ChartView(data: vm.bmiData, type: .bmi)
//            }
            
            ChartView(type: vm.selectedMetric)
                

            // Exercises
            VStack(alignment: .leading, spacing: 0) {
                Text("Exercises")
                
                TabView(selection: $currentExercise.animation(), content: {
                    ForEach(ExerciseType.allCases) { exercise in
                        VStack {
                            exerciseItem(exercise: exercise)
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                            
                            Color.clear
                                .frame(height: 24)
                        }
                        .tag(exercise)
                    }
                })
                .tabViewStyle(.page(indexDisplayMode: .always))
                .containerRelativeFrame(.vertical) { size, axis in
                    size * 0.2
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.25)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            //chatbar
            ChatBar(isNavigatedFromHome: true, namespace: namespace)
                .matchedTransitionSource(id: "chat", in: namespace)

                .environmentObject(chatVM)

            Spacer()
        }
        .padding(.horizontal)
        .background(Color.white)
        // non ui modifier
        
    }

    @ViewBuilder
    private func metricButton(for metric: Metric) -> some View {
        let isSelected = vm.selectedMetric == metric
        let foregroundColor = isSelected ? Color.primaryDark : Color.primaryGreen

        Button(action: {
            withAnimation(.easeInOut) {
                let isCurrentBeforeNext = vm.isCurrentMetricBeforeNext(currentMetric: vm.selectedMetric, nextMetric: metric)
                vm.insertionEdge = isCurrentBeforeNext ? .trailing : .leading
                vm.removalEdge = isCurrentBeforeNext ? .leading : .trailing
                vm.selectedMetric = metric
            }
        }) {
            VStack {
                metric.icon
                    .font(.system(size: 20))

                Text(metric.value)
                    .font(.system(size: 14))
            }
            .foregroundColor(foregroundColor)
            .frame(width: UIScreen.main.bounds.width / 5, height: (UIScreen.main.bounds.width / 5) * 0.7)
            .background(isSelected ? Color.primaryGreen : Color.primaryDark)
            .cornerRadius(12)
        }
    }

    // Exercise Item Component
    private func exerciseItem(exercise: ExerciseType) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedExercise = exercise
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

                HStack(spacing: 15) {
                    // Exercise image
                    exercise.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(.rect(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(exercise.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        Text(exercise.level)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        // Progress bar
                        ZStack(alignment: .leading) {
                            // Background bar
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)

                            // Progress bar
                            Rectangle()
                                .fill(Color.primaryGreen)
                                .frame(width: 200 * exercise.progress, height: 8)
                                .cornerRadius(4)
                        }
                        .frame(width: 200)
                    }

                    Spacer()

                    // Level tag
                    // Text(level)
                    //     .font(.system(size: 12, weight: .medium))
                    //     .foregroundColor(.white)
                    //     .padding(.horizontal, 10)
                    //     .padding(.vertical, 5)
                    //     .background(Color.black)
                    //     .cornerRadius(12)
                }
                .padding()
            }
            .matchedTransitionSource(id: "exercise", in: namespace)
        }
    }
}
