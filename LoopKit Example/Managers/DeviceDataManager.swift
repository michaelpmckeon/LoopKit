//
//  DeviceDataManager.swift
//  LoopKit
//
//  Created by Nathan Racklyeft on 3/18/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import Foundation
import CarbKit
import GlucoseKit
import HealthKit
import InsulinKit
import LoopKit


class DeviceDataManager : CarbStoreDelegate {

    static let shared = DeviceDataManager()

    init() {
        let healthStore = HKHealthStore()

        carbStore = CarbStore(
            healthStore: healthStore,
            carbRatioSchedule: carbRatioSchedule,
            insulinSensitivitySchedule: insulinSensitivitySchedule
        )
        let insulinModel: WalshInsulinModel?
        if let actionDuration = insulinActionDuration {
            insulinModel = WalshInsulinModel(actionDuration: actionDuration)
        } else {
            insulinModel = nil
        }
        doseStore = DoseStore(
            healthStore: healthStore,
            insulinModel: insulinModel,
            basalProfile: basalRateSchedule,
            insulinSensitivitySchedule: insulinSensitivitySchedule
        )
        glucoseStore = GlucoseStore(healthStore: healthStore)
        carbStore?.delegate = self
    }

    // Data stores

    let carbStore: CarbStore!

    let doseStore: DoseStore

    let glucoseStore: GlucoseStore!

    // Settings

    var basalRateSchedule = UserDefaults.standard.basalRateSchedule {
        didSet {
            UserDefaults.standard.basalRateSchedule = basalRateSchedule

            doseStore.basalProfile = basalRateSchedule
        }
    }

    var carbRatioSchedule = UserDefaults.standard.carbRatioSchedule {
        didSet {
            UserDefaults.standard.carbRatioSchedule = carbRatioSchedule

            carbStore?.carbRatioSchedule = carbRatioSchedule
        }
    }

    var insulinActionDuration = UserDefaults.standard.insulinActionDuration {
        didSet {
            UserDefaults.standard.insulinActionDuration = insulinActionDuration

            doseStore.insulinActionDuration = insulinActionDuration
        }
    }

    var insulinSensitivitySchedule = UserDefaults.standard.insulinSensitivitySchedule {
        didSet {
            UserDefaults.standard.insulinSensitivitySchedule = insulinSensitivitySchedule

            carbStore?.insulinSensitivitySchedule = insulinSensitivitySchedule
            doseStore.insulinSensitivitySchedule = insulinSensitivitySchedule
        }
    }

    var glucoseTargetRangeSchedule = UserDefaults.standard.glucoseTargetRangeSchedule {
        didSet {
            UserDefaults.standard.glucoseTargetRangeSchedule = glucoseTargetRangeSchedule
        }
    }

    var pumpID = UserDefaults.standard.pumpID {
        didSet {
            UserDefaults.standard.pumpID = pumpID

            if pumpID != oldValue {
                doseStore.resetPumpData()
            }
        }
    }

    // MARK: CarbStoreDelegate

    func carbStore(_ carbStore: CarbStore, didError error: CarbStore.CarbStoreError) {
        print("carbstore error: \(error)")
    }
}
