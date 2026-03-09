import HealthKit
import Foundation

// MARK: - HealthKit Manager
@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()

    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var todayActiveCalories: Int = 0
    @Published var todaySleepHours: Double = 0
    @Published var latestWeight: Double? = nil
    @Published var restingHeartRate: Int = 0

    // MARK: - Types we read
    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .activeEnergyBurned,
            .bodyMass,
            .heartRate,
            .restingHeartRate,
            .dietaryEnergyConsumed,
            .dietaryProtein,
            .dietaryCarbohydrates,
            .dietaryFatTotal,
            .dietaryWater
        ]
        for id in quantityTypes {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }
        return types
    }

    // MARK: - Types we write
    private var writeTypes: Set<HKSampleType> {
        var types = Set<HKSampleType>()
        let ids: [HKQuantityTypeIdentifier] = [
            .bodyMass,
            .dietaryEnergyConsumed,
            .dietaryProtein,
            .dietaryCarbohydrates,
            .dietaryFatTotal,
            .dietaryWater
        ]
        for id in ids {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        return types
    }

    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
            await fetchAllTodayData()
            return true
        } catch {
            print("HealthKit auth error: \(error)")
            return false
        }
    }

    // MARK: - Fetch All
    func fetchAllTodayData() async {
        async let steps = fetchTodaySteps()
        async let calories = fetchTodayActiveCalories()
        async let sleep = fetchLastNightSleep()
        async let weight = fetchLatestWeight()
        async let hr = fetchRestingHeartRate()

        todaySteps = await steps
        todayActiveCalories = await calories
        todaySleepHours = await sleep
        latestWeight = await weight
        restingHeartRate = await hr
    }

    // MARK: - Steps
    func fetchTodaySteps() async -> Int {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            store.execute(query)
        }
    }

    // MARK: - Active Calories
    func fetchTodayActiveCalories() async -> Int {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return 0 }
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let cals = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                continuation.resume(returning: Int(cals))
            }
            store.execute(query)
        }
    }

    // MARK: - Sleep
    func fetchLastNightSleep() async -> Double {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .hour, value: -18, to: now) ?? now
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let sleepSamples = samples as? [HKCategorySample] ?? []
                let asleepSeconds = sleepSamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                               $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                               $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: asleepSeconds / 3600)
            }
            store.execute(query)
        }
    }

    // MARK: - Latest Weight
    func fetchLatestWeight() async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return nil }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                let sample = samples?.first as? HKQuantitySample
                let kg = sample?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                continuation.resume(returning: kg)
            }
            store.execute(query)
        }
    }

    // MARK: - Resting HR
    func fetchRestingHeartRate() async -> Int {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return 0 }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                let sample = samples?.first as? HKQuantitySample
                let bpm = sample?.quantity.doubleValue(for: HKUnit(from: "count/min")) ?? 0
                continuation.resume(returning: Int(bpm))
            }
            store.execute(query)
        }
    }

    // MARK: - Write Weight
    func saveWeight(_ kg: Double, date: Date = Date()) async -> Bool {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return false }
        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: kg)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        do {
            try await store.save(sample)
            return true
        } catch {
            print("HealthKit save weight error: \(error)")
            return false
        }
    }

    // MARK: - Write Nutrition
    func saveNutrition(
        calories: Double,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        waterL: Double,
        date: Date = Date()
    ) async {
        var samples: [HKQuantitySample] = []

        let nutritionData: [(HKQuantityTypeIdentifier, Double, HKUnit)] = [
            (.dietaryEnergyConsumed, calories, .kilocalorie()),
            (.dietaryProtein,        proteinG, .gram()),
            (.dietaryCarbohydrates,  carbsG,   .gram()),
            (.dietaryFatTotal,       fatG,     .gram()),
            (.dietaryWater,          waterL,   .liter())
        ]

        for (id, value, unit) in nutritionData {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                let quantity = HKQuantity(unit: unit, doubleValue: value)
                samples.append(HKQuantitySample(type: type, quantity: quantity, start: date, end: date))
            }
        }

        do {
            try await store.save(samples)
        } catch {
            print("HealthKit save nutrition error: \(error)")
        }
    }

    // MARK: - Background Delivery
    func enableBackgroundDelivery() async {
        let types: [HKQuantityTypeIdentifier] = [.stepCount, .bodyMass, .activeEnergyBurned]
        for id in types {
            guard let type = HKQuantityType.quantityType(forIdentifier: id) else { continue }
            do {
                try await store.enableBackgroundDelivery(for: type, frequency: .hourly)
            } catch {
                print("Background delivery error for \(id): \(error)")
            }
        }
    }
}

// MARK: - HealthKit Availability Check
extension HealthKitManager {
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func authorizationStatus(for identifier: HKQuantityTypeIdentifier) -> HKAuthorizationStatus {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return .notDetermined }
        return store.authorizationStatus(for: type)
    }
}
