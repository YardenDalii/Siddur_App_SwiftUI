//
//  CalendarView.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 01/08/2025.
//

import SwiftUI


struct CalendarView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack(spacing: 12) {
            Text(Calendar.dayNumber(from: date))
                .background {
                    if date == selectedDate {
                        Circle()
                            .foregroundStyle(CustomPalette.lightBlue.color)
                            .opacity(0.3)
                            .frame(width: 40, height: 40)
                    } else if Calendar.current.isDateInToday(date) {
                        Circle()
                            .foregroundStyle(CustomPalette.golden.color)
                            .opacity(0.3)
                            .frame(width: 40, height: 40)
                    }
                }
        }
        .foregroundStyle(selectedDate == date ? CustomPalette.lightBlue.color : .black)
        .font(.system(.body, design: .rounded, weight: .medium))
        .onTapGesture {
            withAnimation(.easeInOut) {
                selectedDate = date
            }
        }
    }
}



struct WeekView: View {
    let week: Week
    let dragProgress: CGFloat
    let hideDifferentMonth: Bool
    
    @Binding var selectedDate: Date?
    
    init(
        week: Week,
        selectedDate: Binding<Date?>,
        dragProgress: CGFloat,
        hideDifferentMonth: Bool = false
    ) {
        self.week = week
        self.dragProgress = dragProgress
        self.hideDifferentMonth = hideDifferentMonth
        _selectedDate = selectedDate
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            ForEach(week.days, id: \.self) { date in
                DayView(date: date, selectedDate: $selectedDate)
                    .opacity(isDayVisible(for: date) ? 1 : (1 - dragProgress))
                    .frame(maxWidth: .infinity)
                if week.days.last != date {
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func isDayVisible(for date: Date) -> Bool {
        guard hideDifferentMonth else { return true }
        
        switch week.order {
        case .previous,.current:
            guard let last = week.days.last else { return true }
            return Calendar.isSameMonth(date, last)
        case .next:
            guard let first = week.days.first else { return true }
            return Calendar.isSameMonth(date, first)
        }
    }
}


struct WeekCalendarView: View {
    let isDragging: Bool
    
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date?
    
    @State private var weeks: [Week]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(_ title: Binding<String>, selection: Binding<Date?>, focused: Binding<Week>, isDragging: Bool) {
        _title = title
        _focused = focused
        _selection = selection
        self.isDragging = isDragging
        
        let theNearestMonday = Calendar.nearestMonday(from: focused.wrappedValue.days.first ?? .now)
        let currentWeek = Week(
            days: Calendar.currentWeek(from: theNearestMonday),
            order: .current
        )
        
        let previousWeek: Week = if let firstDay = currentWeek.days.first {
            Week(
                days: Calendar.previousWeek(from: firstDay),
                order: .previous
            )
        } else { Week(days: [], order: .previous) }
        
        let nextWeek : Week = if let lastDay = currentWeek.days.last {
            Week(
                days: Calendar.nextWeek(from: lastDay),
                order: .next
            )
        } else { Week(days: [], order: .next) }
        
        _weeks = .init(initialValue: [previousWeek, currentWeek, nextWeek])
        _position = State(initialValue: ScrollPosition(id: focused.id))
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(weeks) { week in
                    VStack {
                        WeekView(week: week, selectedDate: $selection, dragProgress: .zero)
                            .frame(width: calendarWidth, height: CalendarConstants.dayHeight)
                            .onAppear { loadWeek(from: week) }
                    }
                }
            }
            .scrollTargetLayout()
            .frame(height: CalendarConstants.dayHeight)
        }
        .scrollDisabled(isDragging)
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            calendarWidth = newValue
        }
        .onChange(of: position) { _, newValue in
            guard let focusedWeek = weeks.first(where: { $0.id == (newValue.viewID as? String) }) else {
                return }
            focused = focusedWeek
            title = Calendar.monthAndYear(from: focusedWeek.days.last!)
        }
        .onChange(of: selection) { _, newValue in
            guard let date = newValue,
                  let week = weeks.first(where: { $0.days.contains(date) })
            else { return }
            focused = week
        }
    }
}


extension WeekCalendarView {
    func loadWeek(from week: Week) {
        if week.order == .previous, weeks.first == week, let firstDay = week.days.first {
            let previousWeek = Week(days: Calendar.previousWeek(from: firstDay), order: .previous)
            
            var weeks = self.weeks
            weeks.insert(previousWeek, at: 0)
            self.weeks = weeks
        } else if week.order == .next, weeks.last == week, let lastDay = week.days.last {
            let nextWeek = Week(days: Calendar.nextWeek(from: lastDay), order: .next)
            
            var weeks = self.weeks
            weeks.append(nextWeek)
            self.weeks = weeks
        }
    }
}


struct MonthView: View {
    let month: Month
    let dragProgress: CGFloat
        
    @Binding var focused: Week
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack(spacing: .zero) {
            ForEach(month.weeks) { week in
                WeekView(week: week, selectedDate: $selectedDate, dragProgress: dragProgress, hideDifferentMonth: true)
                    .opacity(focused == week ? 1 : dragProgress)
                    .frame(height: CalendarConstants.monthHeight / CGFloat(month.weeks.count))
            }
        }
    }
}


struct MonthCalendarView: View {
    let isDragging: Bool
    let dragProgress: CGFloat
    
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date?
    
    @State private var months: [Month]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(_ title: Binding<String>, selection: Binding<Date?>, focused: Binding<Week>, isDragging: Bool, dragProgress: CGFloat) {
        _title = title
        _focused = focused
        _selection = selection
        self.isDragging = isDragging
        self.dragProgress = dragProgress
        
        let creationDate = focused.wrappedValue.days.last
        var currentMonth = Month(from: creationDate ?? .now, order: .current)
        
        if let selection = selection.wrappedValue,
           let lastDayOfMonth = currentMonth.weeks.first?.days.last,
           !Calendar.isSameMonth(lastDayOfMonth, selection),
           let previousMonth = currentMonth.previousMonth
        {
            if focused.wrappedValue.days.contains(selection) {
                currentMonth = previousMonth
            }
        }
        
        _months = State(
            initialValue: [
                currentMonth.previousMonth,
                currentMonth,
                currentMonth.nextMonth
            ].compactMap(\.self)
        )
        _position = State(initialValue: ScrollPosition(id: currentMonth.id))
    }
    
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(months) { month in
                    VStack {
                        MonthView(month: month, dragProgress: dragProgress, focused: $focused, selectedDate: $selection)
                            .offset(y: (1 - dragProgress) * verticalOffset(for: month))
                            .frame(width: calendarWidth, height: CalendarConstants.monthHeight)
                            .onAppear { loadMonth(from: month) }
                    }
                }
            }
            .scrollTargetLayout()
            .frame(height: CalendarConstants.monthHeight)
        }
        .scrollDisabled(isDragging)
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            calendarWidth = newValue
        }
        .onChange(of: position) { _, newValue in
            guard let focusedMonth = months.first(where: { $0.id == (newValue.viewID as? String) }),
                  let focusedWeek = focusedMonth.weeks.first
            else { return }
            
            if
                let selection,
                focusedMonth.weeks.flatMap(\.days).contains(selection),
                let selectedWeek = focusedMonth.weeks.first(where: { $0.days.contains(selection) })
            {
                focused = selectedWeek
            } else {
                focused = focusedWeek
            }
            
            title = Calendar.monthAndYear(from: focusedWeek.days.last!)
        }
        .onChange(of: selection) { _, newValue in
                guard let date = newValue,
                      let week = months.flatMap(\.days).first(where: { (week) -> Bool in
                          week.days.contains(date)
                      })
            else { return }
            focused = week
        }
        .onChange(of: dragProgress) { _, newValue in
            guard newValue == 1 else { return }
            if let selection,
               let currentMonth = months.first(where: { $0.id == (position.viewID as? String) }),
               currentMonth.weeks.flatMap(\.days).contains(selection),
               let newFocus = currentMonth.weeks.first(where: { $0.days.contains(selection) })
            {
                focused = newFocus
            }
        }
    }
}


extension MonthCalendarView {
    func loadMonth(from month: Month) {
        if month.order == .previous, months.first == month, let previousMonth = month.previousMonth {
            var months = self.months
            months.insert(previousMonth, at: 0)
            self.months = months
        } else if month.order == .next, months.last == month, let nextMonth = month.nextMonth {
            var months = self.months
            months.append(nextMonth)
            self.months = months
        }
    }
    
    func verticalOffset(for month: Month) -> CGFloat {
        guard let index = month.weeks.firstIndex(where: { $0 == focused }) else { return .zero }
        let height = CalendarConstants.monthHeight/CGFloat(month.weeks.count)
        return CGFloat(month.weeks.count - 1)/2 * height - CGFloat(index) * height
    }
}



#Preview {
    CalendarView()
}
