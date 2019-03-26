//
//  ViewController.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 21.11.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var logHistory: [LogEntry] = []
    var selectableRowsIndexes: [Int] = []

    lazy var miBandService = MiBandService(log: { [weak self] logEntry in self?.log(logEntry) },
                                           specialLog: { [weak self] logEntry in self?.specialLog(logEntry) })

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        _ = miBandService
    }

    func log(_ string: LogEntry) {
        logHistory.append(string)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: logHistory.count - 1, section: 0), at: .bottom, animated: true)
    }

    func specialLog(_ string: LogEntry) {
        selectableRowsIndexes.append(self.logHistory.count)
        log(string)
    }

    @IBAction func discoverButtonWasPressed() {
        miBandService.discoverPeripherals()
    }

    @IBAction func disconnectButtonWasPressed() {
        miBandService.disconnect()
    }

    @IBAction func updateButtonWasPressed() {
        miBandService.updateStats()
    }

    @IBAction func startMonitoringHeartRateButtonWasPressed() {
        miBandService.startMonitoringHeartRate()
    }

    @IBAction func stopMonitoringHeartRateButtonWasPressed() {
        miBandService.stopMonitorigHeartRate()
    }

    @IBAction func measureHeartRateButtonWasPressed() {
        miBandService.measureHeartRate()
    }

    @IBAction func callNotificationButtonWasPressed() {
        miBandService.setHighAlert()
    }

    @IBAction func textNotificationButtonWasPressed() {
        miBandService.setMildAlert()
    }

    @IBAction func clearNotificationButtonWasPressed() {
        miBandService.unsetAlert()
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let logEntry = logHistory[indexPath.row]
        let cellIdentifier = logEntry.subtitle.isEmpty ? "SimpleActivityTableViewCell" : "ActivityTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ActivityTableViewCell

        cell.emojiLabel.text = logEntry.emoji
        cell.titleLabel.text = logEntry.title
        cell.subtitleLabel?.text = logEntry.subtitle

        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let peripheralIndex = selectableRowsIndexes.firstIndex(of: indexPath.row) else { return }
        miBandService.connectToPeripheral(at: peripheralIndex)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return selectableRowsIndexes.contains(indexPath.row) ? indexPath : nil
    }
}
