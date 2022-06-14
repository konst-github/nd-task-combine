//
//  ViewModel.swift
//  ND_Task
//
//  Created by Konstantin on 06/06/2022.
//

import UIKit
import Combine

class ViewModel {

	var subjectModelEvents = PassthroughSubject<String, Never>()
	var searchText = CurrentValueSubject<String, Never>("")

	private var subscriptions = Set<AnyCancellable>()

	func subscribe() {
		// when search text changes - just pass it back to view controller to update itself,
		searchText
			.sink(receiveValue: { [weak self] text in
				print("Search Text: \(text)")
				self?.subjectModelEvents.send("Searching")
			})
			.store(in: &subscriptions)

		// data provider is our 'model' , subscribing to pass any model updates to the UI
		DataProvider.shared.subject
			.sink(receiveValue: { [weak self] text in
				self?.subjectModelEvents.send(text)
			})
			.store(in: &subscriptions)
	}

	func loadNews() {
		DataProvider.shared.loadData()
	}

	func news() -> [NewsEntity] {
		// The one source of truth of news - always using filtered ones, as at any moment or UI updates
		// array can be filtered by search field query
		return DataProvider.shared.filteredData(searchText.value)
	}
}
