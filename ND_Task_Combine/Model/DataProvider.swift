//
//  DataProvider.swift
//  ND_Task_Combine
//
//  Created by Konstantin on 14/06/2022.
//

import UIKit
import Combine

class DataProvider {

	static let shared = DataProvider()

	var subject = PassthroughSubject<String, Never>()
	var news: [NewsEntity] = []

	private var subscriptions = Set<AnyCancellable>()

	private init() {}

	func loadData() {
		
		// Load data from server and parse it to NewsEntity objects
		let loader = DataLoaderCombine()
		loader.load()
			.sink(receiveCompletion: { (completion) in
				switch completion {
					case .finished:
						break
					case .failure(let error):
						print(error.localizedDescription)
				}
			}, receiveValue: { [weak self] news in
				self?.updateNews(news)
			})
			.store(in: &subscriptions)
	}

	private func updateNews(_ news: [NewsEntity]) {
		self.news = news
		print("Received \(self.news.count) elements")
		subject.send("News Updated")

		// all entities are coming at once in JSON ,
		// so we loading images when data arrives and is parsed
		loadImages()
	}

	private func loadImages() {
		// Load image and update view model for every single images.
		// We can also group requests f.e. into the group of operations or group publishers etc,
		// but just using this approach
		self.news.forEach { newsEntity in
			newsEntity.image
				.sink(receiveValue: { [weak self] image in
					self?.subject.send("Image Loaded")
				})
				.store(in: &subscriptions)
			newsEntity.loadImage()
		}
	}

	func filteredData(_ filterString: String) -> [NewsEntity] {
		// Filter data - in case of empty string (including initial state of search query) -
		// it will just return full 'news' array
		news.filter { string in
			if filterString.isEmpty {
				return true
			}
			else {
				// Using case insensitive compare here for not to complicate things,
				// plus it is more convenient from the side of UX
				return string.title.containsCaseInsensitive(filterString)
					|| string.description.containsCaseInsensitive(filterString)
			}
		}
	}
}

extension String {
	func containsCaseInsensitive(_ string: String) -> Bool {
		return self.lowercased().contains(string.lowercased())
	}
}
