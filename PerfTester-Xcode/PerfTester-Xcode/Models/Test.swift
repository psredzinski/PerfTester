//
//  Test.swift
//  PerfTester-Xcode
//
//  Created by Patryk Średziński on 08.06.2018.
//  Copyright © 2018 private.perftesterxcode. All rights reserved.
//

import UIKit

class Test {
    
    var title: String = ""
    var desc: String = ""
    var imageName: String = ""
    var parameters: [Double] = []
        
    private var updateBlock: ((_ results: [Double]) -> Void)?

    func prepare(param: Double) {
        assertionFailure()
    }
    
    func doJob(param: Double) {
        assertionFailure()
    }
    
    var results: [Double] = []
    var isTestRunning: [Bool] = []
    private var timers: [DispatchTime] = []
    private var currentParam = 0
    
    func start(updateBlock: @escaping (_ results: [Double]) -> Void) {
        self.updateBlock = updateBlock
        resetTest()
        startSingleVariantAsync(currentParam)
    }
    
    private func resetTest() {
        currentParam = 0
        results = [Double](repeating: 0, count: parameters.count)
        timers = [DispatchTime](repeating: DispatchTime.now(), count: parameters.count)
    }
    
    private func startSingleVariantAsync(_ paramIndex: Int) {
        let deadlineTime = DispatchTime.now() + .milliseconds(250)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.startSingleVariant(paramIndex)
        }
    }
    
    private func startSingleVariant(_ paramIndex: Int) {
        let param = parameters[paramIndex]
        prepare(param: param)
        timers[paramIndex] = DispatchTime.now()
        doJob(param: param)
    }
    
    func finishJob(param: Double) {
        let nanoSeconds = DispatchTime.now().uptimeNanoseconds - timers[currentParam].uptimeNanoseconds
        results[currentParam] = Double(nanoSeconds)/1000000
        
        if let updateBlockSet = updateBlock {
            updateBlockSet(results)
        }
        currentParam += 1
        if currentParam < parameters.count {
            startSingleVariantAsync(currentParam)
        }
    }
}
